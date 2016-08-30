# -*- coding: utf-8 -*-

@[Link(ldflags: "`pkg-config --libs libnotify`")]
lib LibNotify
  struct Error
    domain  : UInt32
    code    : Int32
    message : LibC::Char*
  end

  # The Notification struct is opaque
  #
  # Do not *actually* try to access these, it *will* result in a Segfault
  struct Notification
    app_name      : LibC::Char*
    body          : LibC::Char*
    closed_reason : Int32
    icon_name     : LibC::Char*
    id            : Int32
    summary       : LibC::Char*
  end

  enum Timeout
    Default = -1,
    Never
  end

  enum Urgency
    Low,
    Normal,
    Critical
  end

  struct List end
  struct List
    data : Void*
    next : List*
    prev : List*
  end

  alias Pixbuf = Void*

  fun init            = notify_init(
    app_name : LibC::Char*
  ) : Bool
  fun finalize        = notify_uninit() : Void
  fun initted         = notify_is_initted() : Bool

  fun get_app_name    = notify_get_app_name() : LibC::Char*
  fun set_app_name    = notify_set_app_name(
    app_name : LibC::Char*
  ) : Void
  fun get_server_caps = notify_get_server_caps() : List*
  fun get_server_info = notify_get_server_info(
    ret_name         : LibC::Char**,
    ret_vendor       : LibC::Char**,
    ret_version      : LibC::Char**,
    ret_spec_version : LibC::Char**
  ) : Bool

  fun notif_new               = notify_notification_new(
    summary : LibC::Char*,
    body    : LibC::Char*,
    icon    : LibC::Char*
  ) : Notification*
  fun notif_update            = notify_notification_update(
    notification : Notification*,
    summary      : LibC::Char*,
    body         : LibC::Char*,
    icon         : LibC::Char*
  ) : Bool
  fun notif_show              = notify_notification_show(
    notification : Notification*,
    error        : Error**
  ) : Bool
  fun notif_close             = notify_notification_close(
    notification : Notification*,
    error        : Error**
  ) : Bool
  fun notif_get_closed_reason = notify_notification_get_closed_reason(
    notification : Notification*
  ) : Int32
  fun notif_set_image_pixbuf  = notify_notification_set_image_from_pixbuf(
    notification : Notification*,
    pixbuf       : Pixbuf
  ) : Void
  fun notif_set_app_name      = notify_notification_set_app_name(
    notification : Notification*,
    app_name     : LibC::Char*
  ) : Void
  fun notif_set_timeout       = notify_notification_set_timeout(
    notification : Notification*,
    timeout      : Int32
  ) : Void
  fun notif_set_category      = notify_notification_set_category(
    notification : Notification*,
    category     : LibC::Char*
  ) : Void
  fun notif_set_urgency       = notify_notification_set_urgency(
    notification : Notification*,
    urgency      : Urgency
  ) : Void
  fun notif_add_action        = notify_notification_add_action(
    notification : Notification*,
    action       : LibC::Char*,
    label        : LibC::Char*,
    callback     : (Notification*, LibC::Char*, Void*) -> Void,
    user_data    : Void*,
    free         : Void* -> Void
  ) : Void
end
