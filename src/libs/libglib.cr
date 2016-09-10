# -*- coding: utf-8 -*-

@[Link("glib-2.0")]
lib LibGLib
  struct Error
    domain  : UInt32
    code    : Int32
    message : LibC::Char*
  end

  struct List
    data : Void*
    next : List*
    prev : List*
  end

  fun signal_connect = g_signal_connect_data(
    instance        : Void*,
    detailed_signal : LibC::Char*,
    c_handler       : (Void*) -> Void,
    data            : Void*,
    ptr             : Void*,
    flags           : Int32
  ) : Void*
  fun free           = g_free(Void*) : Void
  fun list_free      = g_list_free(List*) : Void
end
