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
  @state       : State
  @box         : Box(Notification ->)?

  # Creates a new Notification
  #
  # Do not call this method directly,
  # `Notify::Manager#notify` takes care of this
  def initialize(
      @manager  : Notify::Manager,
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

  # Returns the app name this Notification belongs to
  #
  # *Returns* :
  #   - *String*
  getter app_name

  # Returns the notification summary
  #
  # *Returns* :
  #   - *String*
  getter summary

  # Returns the notification body
  #
  # *Returns* :
  #   - *String*
  getter body

  # Returns the notification icon or an empty string if
  # the icon is a `GdkPixbuf`
  #
  # *Returns* :
  #   - *String*
  getter icon

  # Returns the notification state
  #
  # *Returns* :
  #   - *Notify::Notification::State*
  getter state

  # Returns the notification timeout
  #
  # *Returns* :
  #   - *Int32 | LibNotify::Timeout*
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
  # Just as for `Notify::Manager#notify`,
  # you can pass in a Gtk icon name,
  # an absolute file path, or a relative
  # file path if you use `expand: true`
  #
  # *Args*    :
  #   - *icon*   : String
  #   - *expand* : Bool
  # *Returns* :
  #   - *Bool*
  def icon=(icon : String, expand : Bool = false)
    if expand
      icon = File.expand_path(icon)
    end
    ret = LibNotify.notif_update(
      @lib_pointer, @summary, @body, icon
    )
    if ret
      @icon = icon
      return true
    end
    false
  end

  # Sets the notification icon from a `GdkPixbuf`
  #
  # Crystal-Notify does not provide a way to create a
  # Pixbuf.
  #
  # You may use this method if your program
  # uses bindings to Gtk/Gdk, otherwise please use
  # `#icon=(icon : String, expand : Bool = false)`
  #
  # Since Crystal-Notify does not binds Gtk/Gdk, this
  # method accepts a Void*. Be extremely careful what
  # you pass in!
  #
  # *Args*    :
  #   - *pixbuf* : Void*
  # *Returns* :
  #   - *Bool*
  def icon=(pixbuf : Void*)
    self.icon = ""
    LibNotify.notif_set_image_pixbuf(
      @lib_pointer, pixbuf
    )
    true
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
    err = Pointer(GLib::Error).null
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
    err = Pointer(GLib::Error).null
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
    GLib.signal_connect(
      @lib_pointer,
      "closed",
      callback,
      self.as Void*,
      Pointer(Void).null,
      0
    )
  end

  # Gets the closed reason ID
  #
  # **FIXME**: Always returns -1
  #
  # *Returns*   :
  #   - *Int32*
  def closed_reason
    LibNotify.notif_get_closed_reason(@lib_pointer)
  end

  # Adds an action with a callback to the notification
  #
  # **FIXME**: Does not seem to do anything for some reason...
  # The GC sweeps the Box as soon as the specs are done, so LibNotify
  # can't run the callback, but it does not work either when sleeping
  # before exiting.
  #
  # *Args*    :
  #   - *id* : *String* the action ID
  #   - *label* : *String* the action label
  #   - *&callback* : *Notification ->* a block to be run, which receives `self`
  # *Returns* :
  #   - *Bool*
  def add_action(id : String, label : String, &callback : Notification ->)
    return false unless @manager.supports? "actions"
    boxed_data = Box.new(callback)
    @box = boxed_data
    LibNotify.notif_add_action(
      @lib_pointer,
      id, label,
      ->(notif, action, data) {
        data_as_callback = Box(typeof(callback)).unbox(data)
        data_as_callback.call(notif.as Notification)
      },
      boxed_data.as(Void*), nil
    )
    true
  end
end
