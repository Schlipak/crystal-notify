require "./spec_helper"

describe Notify::Manager do
  describe "::new" do
    it "initializes the library" do
      man = Notify::Manager.new("CrystalNotify")
      man.initialized?.should be_true
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

  describe "#server_caps" do
    it "gets the notification server capabilities" do
      man = Notify::Manager.new("CrystalNotify")
      caps = man.server_caps
      STDERR.puts "Server capacities: #{caps}"
    end
  end

  describe "#server_info" do
    it "gets the notification server informations" do
      man = Notify::Manager.new("CrystalNotify")
      infos = man.server_info
      STDERR.puts "Server infos: #{infos}"
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
  end

  describe "#app_name_deep" do
    it "updates all notification's app-name from the manager" do
      man = Notify::Manager.new("CrystalNotify")
      10.times do
        man.notify(
          "Test update app-name",
          "Whatever, this is irrelevant",
          "window-close"
        )
      end
      new_name = "AppNameChanger"
      man.app_name_deep = new_name
      man.each do |notif|
        notif.app_name.should eq(new_name)
      end
    end
  end

  describe "#count" do
    it "checks the amount of notifications in the manager" do
      man = Notify::Manager.new("CrystalNotify")
      42.times do
        man.notify(
          "Temporary notification",
          "You really should not see this",
          "help-faq"
        )
      end
      man.count.should eq(42)
    end
  end

  describe "#[]" do
    it "accesses a specific index in the notification manager" do
      man = Notify::Manager.new("CrystalNotify")
      10.times do |i|
        man.notify(
          "Notif #{i}",
          "Whatever, this is irrelevant",
          "window-close"
        )
      end
      man[3].summary.should eq("Notif 3")
    end
  end

  describe "#clear" do
    it "clears the content of the manager" do
      man = Notify::Manager.new("CrystalNotify")
      10.times do
        man.notify(
          "Temporary notification",
          "Whatever, this is irrelevant",
          "window-close"
        )
      end
      man.clear
      man.count.should eq(0)
      man.empty?.should be_true
    end
  end
end

describe Notify::Notification do
  describe "#summary=" do
    it "updates the notification summary" do
      man = Notify::Manager.new("CrystalNotify")
      bad_summary = "YOU SHOULDN'T SEE THIS"
      notif = man.notify(
        bad_summary,
        "The summary was updated. Trust me, I'm the programmer.",
        "view-refresh"
      )
      notif.should_not be(nil)
      if notif
        notif.summary = "Notification update #1"
        notif.summary.should_not eq(bad_summary)
        notif.show.should be_true
      end
    end
  end

  describe "#body=" do
    it "updates the notification body" do
      man = Notify::Manager.new("CrystalNotify")
      bad_body = "YOU SHOULDN'T SEE THIS"
      notif = man.notify(
        "Notification update #2",
        bad_body,
        "view-refresh"
      )
      notif.should_not be(nil)
      if notif
        notif.body = "This body was updated. Trust me, I'm the programmer."
        notif.body.should_not eq(bad_body)
        notif.show.should be_true
      end
    end
  end

  describe "#icon=" do
    it "updates the notification icon with a string" do
      man = Notify::Manager.new("CrystalNotify")
      bad_icon = "dialog-no"
      notif = man.notify(
        "Notification update #3",
        "The icon was updated. Trust me, I'm... Okay, this is getting old.",
        bad_icon
      )
      notif.should_not be(nil)
      if notif
        notif.icon = "view-refresh"
        notif.icon.should_not eq(bad_icon)
        notif.show.should be_true
      end
    end
  end

  describe "#closed_reason" do
    it "checks the closed_reason of the notification" do
      man = Notify::Manager.new("CrystalNotify")
      notif = man.notify(
        "Test closed_reason",
        "This should not be visible on a server supporting most/all capacities, but might be on a more basic one.",
        "window-close"
      )
      notif.should_not be(nil)
      if notif
        notif.show.should be_true
        notif.closed_reason.should eq(-1)
        notif.close
        notif.closed_reason.should eq(-1)
      end
    end
  end

  describe "#same?" do
    it "checks if two notifications are the same based on their libnotify struct" do
      man = Notify::Manager.new("CrystalNotify")
      notif_one = man.notify(
        "Notif 1",
        "Some content",
        "window-close"
      )
      notif_two = man.notify(
        "Notif 2",
        "Some content",
        "window-close"
      )
      notif_one.should_not be(nil)
      notif_two.should_not be(nil)
      if notif_one && notif_two
        (notif_one.same? notif_one).should be_true
        (notif_two.same? notif_two).should be_true
        (notif_one.same? notif_two).should be_false
      end
    end
  end

  describe "misc tests" do
    it "checks that a notification can be shown only once" do
      man = Notify::Manager.new("CrystalNotify")
      notif = man.notify(
      "Multiple calls to #show",
      "This is the first and only time you should see me.",
      "gtk-about"
      )
      notif.should_not be(nil)
      if notif
        notif.show.should be_true
        10.times do
          notif.show.should be_false
        end
      end
    end
  end
end
