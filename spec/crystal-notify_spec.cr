require "./spec_helper"

describe Notify::Manager do
  it "initializes the library" do
    man = Notify::Manager.new("CrystalNotify")
    man.initialized?.should eq(true)
    man.finalize
  end

  it "gets the app name" do
    app_name = "CrystalNotify"
    man = Notify::Manager.new(app_name)
    man.app_name.should eq(app_name)
    man.finalize
  end

  it "sets the app name" do
    app_name = "HeartOfGold"
    man = Notify::Manager.new("CrystalNotify")
    man.app_name = app_name
    man.app_name.should eq(app_name)
    man.finalize
  end

  it "gets the notification server capabilities" do
    man = Notify::Manager.new("CrystalNotify")
    caps = man.server_caps
    STDERR.puts "Server capacities: #{caps}"
    man.finalize
  end

  it "gets the notification server informations" do
    man = Notify::Manager.new("CrystalNotify")
    infos = man.server_info
    STDERR.puts "Server infos: #{infos}"
    man.finalize
  end

  it "shows a basic notification" do
    man = Notify::Manager.new("CrystalNotify")
    notif = man.notify(
      "It works!",
      "This is a basic notification issued by Crystal-Notify.",
      "dialog-ok"
    )
    notif.should_not be(nil)
    if notif
      notif.show.should be_true
    end
    man.finalize
  end

  it "shows a notification and updates its summary" do
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
    man.finalize
  end

  it "shows a notification and updates its body" do
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
    man.finalize
  end

  it "shows a notification and updates its icon" do
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
    man.finalize
  end

  it "checks the closed_reason of the notification" do
    man = Notify::Manager.new("CrystalNotify")
    notif = man.notify(
      "Test closed_reason",
      "This checks the closed_reason of the notification",
      "window-close"
    )
    notif.should_not be(nil)
    if notif
      notif.show.should be_true
      notif.closed_reason.should eq(-1)
      notif.close
      notif.closed_reason.should eq(-1)
    end
    man.finalize
  end

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
    man.finalize
  end

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
    man.finalize
  end

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
    man.finalize
  end

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
    man.finalize
  end
end
