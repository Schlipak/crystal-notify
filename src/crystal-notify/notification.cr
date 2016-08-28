# -*- coding: utf-8 -*-

class Notify::Notification
  class InstantiationException < Exception
  end

  @lib_notif : LibNotify::Notification*

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

  def show
    LibNotify.notif_show(
      @lib_notif,
      Pointer(LibNotify::Error*).null
    )
  end
end
