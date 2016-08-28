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
      "object-rotate"
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
      "object-rotate"
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
      "The icon was updated. Trust me, I'm... Oh, this is getting old already.",
      bad_icon
    )
    notif.should_not be(nil)
    if notif
      notif.icon = "object-rotate"
      notif.icon.should_not eq(bad_icon)
      notif.show.should be_true
    end
    man.finalize
  end
end
