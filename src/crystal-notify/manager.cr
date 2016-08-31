# -*- coding: utf-8 -*-

require "./libnotify"

# The notification manager class
#
# This is an abstraction of the several libnotify functions,
# and allows multiple actions on native desktop notifications,
# reguardless of the WindowManager used by the user.
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
  def initialize(@app_name : String)
    @notifications = [] of Notification
    unless LibNotify.init(@app_name)
      raise InitializationException.new("Error while initializing libnotify")
    end
  end

  # Gets the internal notification array
  #
  # *Returns* :
  #   - *Array(LibNotify::Notification)*
  getter notifications

  # Frees up the libnotify instance. Makes *self* unusable.
  #
  # Call this only if needed, otherwise the CG will take care of it.
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
  #   - *app_name*  : String
  def app_name=(app_name : String)
    @app_name = app_name
    LibNotify.set_app_name(@app_name)
  end

  # Sets the current application name, cascading the
  # change to all notifications currently held by the
  # manager
  #
  # *Args*  :
  #   - *app_name*  : String
  def app_name_deep=(app_name : String)
    self.app_name = app_name
    @notifications.each do |notif|
      notif.app_name = @app_name
    end
  end

  # Gives the list of the features the current
  # notification server supports
  #
  # *Returns* :
  #   - *Array(String)*
  #
  # ```
  # man = Notify::Manager.new "MyApp"
  # man.server_caps #=> ["actions", "actions-icons", "body", "body-markup", "icon-static"]
  # ```
  def server_caps
    caps = [] of String
    head = LibNotify.get_server_caps
    node = head
    while node.value.next
      caps << String.new(node.value.data as LibC::Char*)
      node = node.value.next
    end
    node = head
    while node.value.next
      nexxt = node.value.next
      GLib.free(node.value.data)
      node = nexxt
    end
    GLib.list_free(head)
    caps
  end

  # Gives some infos about the current notification server
  #
  # *Returns* :
  #   - *NamedTuple(name: String, vendor: String, version: String, spec_version: String)*
  #
  # ```
  # man = Notify::Manager.new "MyApp"
  # man.server_info #=> {name: "cinnamon", vendor: "GNOME", version: "3.0.7", spec_version: "1.2"}
  # ```
  def server_info
    LibNotify.get_server_info(
      out name,
      out vendor,
      out version,
      out spec_version
    )

    infos = {
      name:         (name ? String.new(name) : ""),
      vendor:       (vendor ? String.new(vendor) : ""),
      version:      (version ? String.new(version) : ""),
      spec_version: (spec_version ? String.new(spec_version) : "")
    }

    GLib.free(name)
    GLib.free(vendor)
    GLib.free(version)
    GLib.free(spec_version)

    infos
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

    notif = Notification.new(@app_name, summary, body, icon)
    @notifications << notif
    return notif
  end

  # Displays all the notifications held by the manager
  def show_all
    @notifications.each do |notif|
      notif.show
    end
  end

  # Closes all the notifications held by the manager
  def close_all
    @notifications.each do |notif|
      notif.close
    end
  end

  # Iterates over all the notifications held by the manager
  # and yields them to the calling block
  def each
    @notifications.each do |notif|
      yield notif
    end
  end

  # Closes all notifications and removes them from the manager
  def clear
    self.close_all
    @notifications.clear
  end

  # Returns the number of notifications held by the manager
  #
  # *Returns*   :
  #   - *Int*
  def count
    @notifications.size
  end

  # Returns whether the manager contains notifications or not
  #
  # *Returns*   :
  #   - *Bool*
  def empty?
    self.count == 0
  end

  # Get the nth notification held by the manager
  #
  # *Args*    :
  #   - *index* : Int
  # *Raises*  :
  #   - `IndexError` if trying to access a notification outside of range
  def [](index : Int)
    @notifications[index]
  end
end
