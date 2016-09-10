# -*- coding: utf-8 -*-

# The notification server informations
class Notify::ServerInfo
  # Do not initialize this class yourself,
  # Notify::Manager#server_info does it for you.
  def initialize(
      name         : LibC::Char*,
      vendor       : LibC::Char*,
      version      : LibC::Char*,
      spec_version : LibC::Char*
    )

    @name         = name ? String.new(name) : ""
    @vendor       = vendor ? String.new(vendor) : ""
    @version      = version ? String.new(version) : ""
    @spec_version = spec_version ? String.new(spec_version) : ""

    LibGLib.free(name)
    LibGLib.free(vendor)
    LibGLib.free(version)
    LibGLib.free(spec_version)
  end

  # Gets the notification server name
  getter name

  # Gets the notification server vendor
  getter vendor

  # Gets the version of the notification server
  getter version

  # Gets the minimum version of libnotify required
  # by the notification server
  getter spec_version

  # Returns a textual description of the notification
  # server informations
  #
  # *Returns* :
  #   - *String*
  def to_s
    [
      "Notification server `#{@name} v#{@version}` (#{@vendor})",
      "Compliant with libnotify >= #{@spec_version}"
    ].join("\n")
  end
end
