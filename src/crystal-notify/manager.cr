# -*- coding: utf-8 -*-

require "./libnotify"

# The notification manager class
#
# This is an abstraction of the several libnotify functions,
# and allows multiple actions on native desktop notifications,
# reguardless of the WindowManager used by the user.
#
# The `#finalize` method shall always be called to cleanup
# the library
class Notify::Manager
  # Exception raised when failing to initialize libnotify
  class InitializationException < Exception
  end

  # Instanciates a new Notify::Manager with the given application
  # name
  #
  # *Args*    :
  #   - *app_name* : String
  # *Returns* :
  #   - Class instance
  # *Raises*  :
  #   - `InitializationException`
  def initialize(app_name : String)
    @notifications = [] of Notification
    unless LibNotify.init(app_name)
      raise InitializationException.new("Error while initializing libnotify")
    end
  end

  # Gets the internal notification array
  #
  # *Returns* :
  #   - *Array(LibNotify::Notification)*
  getter notification

  # Frees up the libnotify instance. Makes *self* unusable.
  def finalize
    LibNotify.finalize
  end

  # Checks if the libnotify is initialized
  #
  # *Returns* :
  #   - *Bool*
  def initialized?
    LibNotify.initted
  end

  # Gets the current application name
  #
  # *Returns* :
  #   - *String*
  def app_name
    bytes = LibNotify.get_app_name
    if bytes
      String.new(bytes)
    else
      ""
    end
  end

  # Sets the current application name
  #
  # *Args*  :
  #   - *app_name* : String
  def app_name=(app_name : String)
    LibNotify.set_app_name(app_name)
  end

  # Gives the list of the features the current
  # notification server supports
  #
  # *Returns* :
  #   - *Array(String)*
  def server_caps
    caps = [] of String
    strukt = LibNotify.get_server_caps.value
    while strukt.next
      caps << String.new(strukt.data as LibC::Char*)
      strukt = strukt.next.value
    end
    caps
  end

  # Gives some infos about the current notification server
  #
  # *Returns* :
  #   - *NamedTuple(name: String, vendor: String, version: String, spec_version: String)*
  def server_info
    LibNotify.get_server_info(
      out name,
      out vendor,
      out version,
      out spec_version
    )

    {
      name:         String.new(name),
      vendor:       String.new(vendor),
      version:      String.new(version),
      spec_version: String.new(spec_version)
    }
  end

  # Creates a new notification
  #
  # *Args*  :
  #   - *summary* : String
  #   - *body*    : String
  #   - *icon*    : String
  #
  # *icon* is the GTK name for the icon you want.
  # Check out the GTK spec to list some of them:
  #
  # https://developer.gnome.org/icon-naming-spec/
  def notify(
      summary : String,
      body    : String = "",
      icon    : String = ""
    )

    notif = Notification.new(summary, body, icon)
    @notifications << notif
    return notif
  end
end
