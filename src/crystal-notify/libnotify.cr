# -*- coding: utf-8 -*-

@[Link("notify")]
lib LibNotify
  NOTIFY_EXPIRES_DEFAULT = -1
  NOTIFY_EXPIRES_NEVER   = 0

  struct Error
    domain  : UInt32
    code    : Int32
    message : LibC::Char*
  end

  struct Notification
    app_name      : LibC::Char*
    body          : LibC::Char*
    closed_reason : Int32
    icon_name     : LibC::Char*
    id            : Int32
    summary       : LibC::Char*
  end

  enum Urgency
    LOW,
    NORMAL,
    CRITICAL
  end

  struct List
  end

  struct List
    data : Void*
    next : List*
    prev : List*
  end

  fun init            = notify_init(app_name : LibC::Char*) : Bool
  fun finalize        = notify_uninit() : Void
  fun initted         = notify_is_initted() : Bool

  fun get_app_name    = notify_get_app_name() : LibC::Char*
  fun set_app_name    = notify_set_app_name(app_name : LibC::Char*) : Void
  fun get_server_caps = notify_get_server_caps() : List*
  fun get_server_info = notify_get_server_info(
    ret_name         : LibC::Char**,
    ret_vendor       : LibC::Char**,
    ret_version      : LibC::Char**,
    ret_spec_version : LibC::Char**
  ) : Bool

  fun notif_new = notify_notification_new(
    summary : LibC::Char*,
    body    : LibC::Char*,
    icon    : LibC::Char*
  ) : Notification*
  fun notif_update = notify_notification_update(
    notification  : Notification*,
    summary       : LibC::Char*,
    body          : LibC::Char*,
    icon          : LibC::Char*
  ) : Bool
  fun notif_show = notify_notification_show(
    notification : Notification*,
    error        : Error**
  ) : Bool
end
