# -*- coding: utf-8 -*-

# The Notification class
#
# Encapsulates the `LibNotify::Notification` struct
class Notify::Notification
  # Exception raised when failing to instantiate a notification
  class InstantiationException < Exception
  end

  # :nodoc:
  enum State
    Hidden = 0,
    Shown,
    Closed
  end

  @lib_notif : LibNotify::Notification*
  @state     : State

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
    @lib_notif = LibNotify.notif_new(summary, body, icon)
    if @lib_notif.null?
      raise InstantiationException.new("Error while creating instance of libnotify notification")
    end
  end

  protected getter lib_notif

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
    @lib_notif == other.lib_notif
  end

  getter app_name
  getter summary
  getter body
  getter icon
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
      @lib_notif, summary, @body, @icon
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
      @lib_notif, @summary, body, @icon
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
      @lib_notif, @summary, @body, icon
    )
    if ret
      @icon = icon
      return true
    end
    false
  end

  # :nodoc:
  def icon=(pixbuf : LibNotify::Pixbuf)
    LibNotify.notif_set_image_pixbuf(@lib_notif, pixbuf)
  end

  # Sets the current application name
  #
  # *Args*  :
  #   - *app_name* : String
  def app_name=(app_name : String)
    @app_name = app_name
    LibNotify.notif_set_app_name(
      @lib_notif, @app_name
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
    LibNotify.notif_set_timeout(@lib_notif, time)
  end

  # Displays the notification
  #
  # *Returns*   :
  #   - *Bool*
  def show
    return false if @state >= State::Shown
    ret = LibNotify.notif_show(
      @lib_notif,
      Pointer(LibNotify::Error*).null
    )
    if ret
      @state = State::Shown
    end
    ret
  end

  # Closes the notification
  #
  # *Returns*   :
  #   - *Bool*
  def close
    LibNotify.notif_close(
      @lib_notif,
      Pointer(LibNotify::Error*).null
    )
    @state = State::Closed
  end

  # **FIXME**: Always returns -1 since we don't have access to
  # signal_connect to use the 'closed' signal.
  #
  # Gets the closed reason ID
  #
  # *Returns*   :
  #   - *Int32*
  def closed_reason
    LibNotify.notif_get_closed_reason(@lib_notif)
  end
end
