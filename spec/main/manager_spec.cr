require "../spec_helper"

describe Notify::Manager do
  describe "::new" do
    it "initializes the library" do
      man = Notify::Manager.new("CrystalNotify")
      man.initialized?.should be_true
    end
  end

  describe "#[]" do
    it "gets the nth notification" do
      notif = nil
      man = Notify::Manager.new("CrystalNotify")
      5.times do
        notif = man.notify("TMP", "TMP")
      end
      if notif
        man[4].should eq(notif)
      end
    end
  end

  describe "#app_name" do
    it "gets the app name" do
      app_name = "CrystalNotify"
      man = Notify::Manager.new(app_name)
      man.app_name.should eq(app_name)
    end
  end

  describe "#app_name=" do
    it "sets the app name" do
      app_name = "HeartOfGold"
      man = Notify::Manager.new("CrystalNotify")
      man.app_name = app_name
      man.app_name.should eq(app_name)
    end
  end

  describe "#app_name_deep" do
    it "updates all notification's app-name from the manager" do
      man = Notify::Manager.new("CrystalNotify")
      10.times do
        man.notify("TMP", "TMP")
      end
      new_name = "AppNameChanger"
      man.app_name_deep = new_name
      man.each do |notif|
        notif.app_name.should eq(new_name)
      end
    end
  end

  describe "#clear" do
    it "clears the content of the manager" do
      man = Notify::Manager.new("CrystalNotify")
      10.times do
        man.notify("TMP", "TMP")
      end
      man.clear
      man.count.should eq(0)
      man.empty?.should be_true
    end
  end

  describe "#close_all" do
    it "closes all the notifications" do
      man = Notify::Manager.new("CrystalNotify")
      10.times do
        man.notify("TMP", "TMP")
      end
      man.show_all
      man.close_all
      man.each do |notif|
        notif.state.should eq(Notify::Notification::State::Closed)
      end
    end
  end

  describe "#count" do
    it "checks the amount of notifications in the manager" do
      man = Notify::Manager.new("CrystalNotify")
      10.times do
        man.notify("TMP", "TMP")
      end
      man.count.should eq(10)
    end
  end

  describe "#each" do
    it "iterates over the notifications" do
      man = Notify::Manager.new("CrystalNotify")
      10.times do
        man.notify("TMP", "TMP")
      end
      index = 0
      man.each do |notif|
        notif.should eq(man[index])
        index += 1
      end
    end
  end

  describe "#empty?" do
    it "checks if the manager contains notifications" do
      man = Notify::Manager.new("CrystalNotify")
      man.empty?.should be_true
      man.notify("TMP", "TMP")
      man.empty?.should be_false
    end
  end

  describe "#finalize" do
    it "frees the library resources" do
      man = Notify::Manager.new("CrystalNotify")
      man.finalize
      man.initialized?.should be_false
    end
  end

  describe "#initialized?" do
    it "checks if the LibNotify is initialized" do
      man = Notify::Manager.new("CrystalNotify")
      man.initialized?.should be_true
    end
  end

  describe "#notifications" do
    it "returns the underlying Notification array" do
      man = Notify::Manager.new("CrystalNotify")
      10.times do
        man.notify("TMP", "TMP")
      end
      notifs = man.notifications
      notifs.each_with_index do |notif, index|
        notif.should eq(man[index])
      end
    end
  end

  describe "#notify" do
    it "shows a basic notification" do
      man = Notify::Manager.new("CrystalNotify")
      notif = man.notify(
        "Crystal-Notify v#{Notify::VERSION}",
        "This is a basic notification issued by Crystal-Notify.",
        "dialog-ok"
      )
      notif.should_not be(nil)
      if notif
        notif.show.should be_true
      end
    end

    it "shows a notification with a local icon" do
      man = Notify::Manager.new("CrystalNotify")
      icon_name = "res/icon.svg"
      notif = man.notify(
        "Crystal-Notify v#{Notify::VERSION}",
        "This is a notification with expand: true",
        icon_name,
        expand: true
      )
      notif.should_not be(nil)
      if notif
        notif.show.should be_true
        notif.icon.should eq(File.expand_path(icon_name))
      end
    end

    it "shows a notification with markup if available" do
      man = Notify::Manager.new("CrystalNotify")
      notif = man.notify(
        "Markup test",
        "This is a <b>Markup</b> test, you <i>should</i> see this body with a few <u>styles</u> applied to it if your notification server supports `body-markup`."
      )
      notif.should_not be(nil)
      if notif
        notif.show.should be_true
      end
    end
  end

  describe "#server_caps" do
    it "gets the notification server capabilities" do
      man = Notify::Manager.new("CrystalNotify")
      caps = man.server_caps
      caps.should be_a(Array(String))
    end
  end

  describe "#server_info" do
    it "gets the notification server informations" do
      man = Notify::Manager.new("CrystalNotify")
      infos = man.server_info
      infos.should be_a(Notify::ServerInfo)
    end
  end

  describe "#show_all" do
    it "displays all the notifications in queue" do
      man = Notify::Manager.new("CrystalNotify")
      3.times do |i|
        man.notify(
          "Temporary test #show_all ##{i}",
          "You should not see this, unless your notification server does not support closing notifications programmatically"
        )
      end
      man.show_all
      man.each do |notif|
        notif.state.should eq(Notify::Notification::State::Shown)
        notif.close
      end
    end
  end

  describe "#supports?" do
    it "checks if the notifications server supports a capability" do
      man = Notify::Manager.new("CrystalNotify")
      man.supports?("body-markup").should be_a(Bool)
    end
  end
end
