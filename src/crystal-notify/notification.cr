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
  @state  : State

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
    @lib_pointer = LibNotify.notif_new(summary, body, icon)
    if @lib_pointer.null?
      raise InstantiationException.new("Error while creating instance of libnotify notification")
    end
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

  # :nodoc:
  def icon=(pixbuf : LibNotify::Pixbuf)
    LibNotify.notif_set_image_pixbuf(@lib_pointer, pixbuf)
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
    err = GLib::Error.new
    if LibNotify.notif_show(@lib_pointer, pointerof(err))
      @state = State::Shown
      true
    else
      unless err.domain == 0
        STDERR.puts String.new(err.message)
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
    err = GLib::Error.new
    if LibNotify.notif_close(@lib_pointer, pointerof(err))
      @state = State::Closed
      true
    else
      unless err.domain == 0
        STDERR.puts String.new(err.message)
      end
      false
    end
  end

  # :nodoc:
  def on_close(callback : Proc)
    GLib.signal_connect(
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
