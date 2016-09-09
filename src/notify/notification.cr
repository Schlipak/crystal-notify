# -*- coding: utf-8 -*-

# The Notification class
#
# Encapsulates the `LibNotify::Notification` struct
class Notify::Notification
  # Exception raised when failing to instantiate a notification
  class InstantiationException < Exception
  end

  # The Notification state
  enum State
    Hidden = 0,
    Shown,
    Closed
  end

  @lib_pointer : LibNotify::Notification*
  @pixbuf      : LibGdk::Pixbuf*
  @state       : State

  # Creates a new Notification
  #
  # Do not call this method directly,
  # `Notify::Manager#notify` takes care of this
  def initialize(
      @app_name : String,
      @summary  : String,
      @body     : String = "",
      @icon     : String = ""
    )

    @state = State::Hidden
    @timeout = LibNotify::Timeout::Default
    @pixbuf = Pointer(LibGdk::Pixbuf).null
    @lib_pointer = LibNotify.notif_new(summary, body, icon)
    if @lib_pointer.null?
      raise InstantiationException.new("Error while creating instance of libnotify notification")
    end
  end

  # :nodoc:
  def finalize
    free_pixbuf
  end

  protected getter lib_pointer

  # Returns true if two notifications are the same
  #
  # The check is performed based on the internal libnotify struct
  #
  # Use the standard #== to check for object equality
  #
  # *Args*    :
  #   - *other* : Notification
  # *Returns* :
  #   - *Bool*
  def same?(other : Notification)
    @lib_pointer == other.lib_pointer
  end

  getter app_name
  getter summary
  getter body
  getter icon
  getter state
  getter timeout

  # Sets the notification summary and updates
  # the `LibNotify::Notification` struct
  #
  # *Args*    :
  #   - *summary* : String
  # *Returns* :
  #   - *Bool*
  def summary=(summary : String)
    ret = LibNotify.notif_update(
      @lib_pointer, summary, @body, @icon
    )
    if ret
      @summary = summary
      return true
    end
    false
  end

  # Sets the notification body and updates
  # the `LibNotify::Notification` struct
  #
  # *Args*    :
  #   - *body* : String
  # *Returns* :
  #   - *Bool*
  def body=(body : String)
    ret = LibNotify.notif_update(
      @lib_pointer, @summary, body, @icon
    )
    if ret
      @body = body
      return true
    end
    false
  end

  # Sets the notification icon and updates
  # the `LibNotify::Notification` struct
  #
  # *Args*    :
  #   - *icon* : String
  # *Returns* :
  #   - *Bool*
  def icon=(icon : String)
    ret = LibNotify.notif_update(
      @lib_pointer, @summary, @body, icon
    )
    if ret
      @icon = icon
      return true
    end
    false
  end

  # Sets the notification icon from a filename
  #
  # The file path must be accessible, and the file must
  # be a valid image.
  #
  # Internally, the file is loaded using
  # `gdk_pixbuf_new_from_file` from the libgdk_pixbuf.
  # Please make sure your image is compatible with this library.
  #
  # *Args*    :
  #   - *filename* : String
  # *Returns* :
  #   - *Bool*
  def icon_load(filename : String)
    err = Pointer(LibGLib::Error).null
    pixbuf = LibGdk.new_from_file(
      filename,
      pointerof(err)
    )
    if pixbuf.null?
      if !err.null? && err.value.domain != 0
        STDERR.puts String.new(err.value.message)
      end
      return false
    end
    free_pixbuf
    self.icon = ""
    @pixbuf = pixbuf
    LibNotify.notif_set_image_pixbuf(@lib_pointer, @pixbuf)
    true
  end

  # :nodoc:
  private def free_pixbuf
    return if @pixbuf.null?
    LibGObject.unref(@pixbuf)
    @pixbuf = Pointer(LibGdk::Pixbuf).null
  end

  # Sets the current application name
  #
  # *Args*  :
  #   - *app_name* : String
  def app_name=(app_name : String)
    @app_name = app_name
    LibNotify.notif_set_app_name(
      @lib_pointer, @app_name
    )
  end

  # Sets the timeout of the notification
  #
  # To set as default, pass *LibNotify::Timeout::Default*.
  #
  # To set the notification to never expire,
  # pass *LibNotify::Timeout::Never*.
  #
  # To set an arbitrary timeout, pass your desired
  # time in milliseconds.
  #
  # Note that the timeout setting may be entirely ignored by the
  # notification server if not supported
  #
  # *Args*    :
  #   - *timeout* : Int32
  def timeout=(time : Int32)
    @timeout = time
    LibNotify.notif_set_timeout(@lib_pointer, time)
  end

  # Displays the notification
  #
  # *Returns*   :
  #   - *Bool*
  def show
    return false if @state >= State::Shown
    err = Pointer(LibGLib::Error).null
    if LibNotify.notif_show(@lib_pointer, pointerof(err))
      @state = State::Shown
      true
    else
      if !err.null? && err.value.domain != 0
        STDERR.puts String.new(err.value.message)
      end
      false
    end
  end

  # Closes the notification
  #
  # *Returns*   :
  #   - *Bool*
  def close
    return false if @state == State::Closed
    err = Pointer(LibGLib::Error).null
    if LibNotify.notif_close(@lib_pointer, pointerof(err))
      @state = State::Closed
      true
    else
      if !err.null? && err.value.domain != 0
        STDERR.puts String.new(err.value.message)
      end
      false
    end
  end

  # :nodoc:
  def on_close(callback : Proc)
    LibGLib.signal_connect(
      @lib_pointer,
      "closed",
      callback,
      self as Void*,
      Pointer(Void).null,
      0
    )
  end

  # **FIXME**: Always returns -1 since we don't have access to
  # signal_connect to use the 'closed' signal.
  #
  # Gets the closed reason ID
  #
  # *Returns*   :
  #   - *Int32*
  def closed_reason
    LibNotify.notif_get_closed_reason(@lib_pointer)
  end
end
