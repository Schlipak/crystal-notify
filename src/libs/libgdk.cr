# -*- coding: utf-8 -*-

require "./libgobject"
require "./libglib"

@[Link("gdk_pixbuf-2.0")]
lib LibGdk
  alias Pixbuf = LibGObject::GObject

  fun new_from_file = gdk_pixbuf_new_from_file(
    filename : LibC::Char*,
    error    : LibGLib::Error**
  ) : Pixbuf*
end
