# -*- coding: utf-8 -*-

# The Notification class
#
# Encapsulates the LibNotify::Notification struct
class Notify::Notification
  # Exception raised when failing to instantiate a notification
  class InstantiationException < Exception
  end

  @lib_notif : LibNotify::Notification*

  # Creates a new Notification
  #
  # Do not call this method directly,
  # `Notify::Manager#notify` takes care of this
  def initialize(
      @summary : String,
      @body    : String = "",
      @icon    : String = ""
    )

    @lib_notif = LibNotify.notif_new(summary, body, icon)
    if @lib_notif.null?
      raise InstantiationException.new("Error while creating instance of libnotify notification")
    end
  end

  getter summary
  getter body
  getter icon

    # Sets the notification summary and updates
    # the LibNotify::Notification struct
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
  # the LibNotify::Notification struct
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
  # the LibNotify::Notification struct
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

  # Displays the notification
  #
  # *Returns*   :
  #   - *Bool*
  def show
    LibNotify.notif_show(
      @lib_notif,
      Pointer(LibNotify::Error*).null
    )
  end
end
