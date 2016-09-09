# -*- coding: utf-8 -*-

@[Link("gobject-2.0")]
lib LibGObject
  alias GObject = Void

  fun unref = g_object_unref(
    object : GObject*
  ) : Void
end
