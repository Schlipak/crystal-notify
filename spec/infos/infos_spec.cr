require "../spec_helper"

describe "Server infos tests" do
  describe "#server_infos" do
    it "prints the notification server infos" do
      man = Notify::Manager.new "Test"
      infos = man.server_info
      STDERR.puts "\nCrystal-Notify v#{Notify::VERSION}"
      STDERR.puts infos.to_s
      man.finalize
    end
  end

  describe "#server_caps" do
    it "prints and describes the server capabilities" do
      man = Notify::Manager.new "Test"
      caps = man.server_caps
      len = caps.max_by(&.size).size
      STDERR.puts "\nServer capabilities"
      caps.each do |cap|
        STDERR.puts " #{cap.ljust(len)} => #{man.describe_cap(cap)}"
      end
      man.finalize
    end
  end
end
