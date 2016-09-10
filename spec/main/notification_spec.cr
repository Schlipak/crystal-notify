require "../spec_helper"

describe Notify::Notification do
  describe "#show" do
    it "displays the notification" do
      man = Notify::Manager.new("CrystalNotify")
      notif = man.notify(
        "Test Notification#show",
        "Yay, it works!",
        "dialog-ok"
      )
      notif.should_not be(nil)
      if notif
        notif.show.should be_true
      end
    end
  end

  describe "#app_name" do
    it "gets the app name" do
      app_name = "CrystalNotify"
      man = Notify::Manager.new(app_name)
      notif = man.notify(
        "A notification",
        "Its contents"
      )
      notif.should_not be(nil)
      if notif
        notif.app_name.should eq(app_name)
      end
    end
  end

  describe "#app_name=" do
    it "sets the app name" do
      man = Notify::Manager.new("CrystalNotify")
      notif = man.notify(
        "A notification",
        "Its contents"
      )
      notif.should_not be(nil)
      if notif
        new_name = "Test App"
        notif.app_name = new_name
        notif.app_name.should eq(new_name)
      end
    end
  end

  describe "#body" do
    it "gets the notification body" do
      notif_body = "This is the content"
      man = Notify::Manager.new("CrystalNotify")
      notif = man.notify(
        "A notification",
        notif_body
      )
      notif.should_not be(nil)
      if notif
        notif.body.should eq(notif_body)
      end
    end
  end

  describe "#body=" do
    it "updates the notification body" do
      man = Notify::Manager.new("CrystalNotify")
      bad_body = "THIS IS BAD"
      notif = man.notify(
        "Notification update #2",
        bad_body
      )
      notif.should_not be(nil)
      if notif
        notif.body = "This body was updated. Trust me, I'm the programmer."
        notif.body.should_not eq(bad_body)
      end
    end
  end

  describe "#close" do
    it "closes the notification" do
      man = Notify::Manager.new("CrystalNotify")
      notif = man.notify(
        "Test #close",
        "You should not see this notification, unless your notification server does not support closing the notification programmatically"
      )
      notif.should_not be(nil)
      if notif
        notif.show.should be_true
        notif.state.should eq(Notify::Notification::State::Shown)
        notif.close
        notif.state.should eq(Notify::Notification::State::Closed)
      end
    end
  end

  describe "#closed_reason" do
    it "checks the closed_reason of the notification" do
      man = Notify::Manager.new("CrystalNotify")
      notif = man.notify(
        "Test closed_reason",
        "This should not be visible on a server supporting most/all capabilities, but might be on a more basic one."
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

  describe "#icon" do
    it "gets the notification icon" do
      icon_name = "view-refresh"
      man = Notify::Manager.new("CrystalNotify")
      notif = man.notify(
        "A notification",
        "Its content",
        icon_name
      )
      notif.should_not be(nil)
      if notif
        notif.icon.should eq(icon_name)
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
      end
    end
  end

  describe "#icon_load" do
    it "updates the notification icon from a file" do
      man = Notify::Manager.new("CrystalNotify")
      notif = man.notify(
        "Crystal-Notify",
        "The icon was loaded from a file.",
        "dialog-no"
      )
      notif.should_not be(nil)
      if notif
        notif.icon_load("./res/icon.svg").should be_true
        notif.icon.should eq("")
        notif.show.should be_true
      end
    end
  end

  describe "#same?" do
    it "checks if two notifications are the same based on their libnotify struct" do
      man = Notify::Manager.new("CrystalNotify")
      notif_one = man.notify(
        "Notif 1",
        "Some content"
      )
      notif_two = man.notify(
        "Notif 2",
        "Some content"
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

  # describe "#on_close" do
  #   it "adds a callback on notification close" do
  #     man = Notify::Manager.new("CrystalNotify")
  #     notif = man.notify(
  #       "Test #on_close callback",
  #       "This should print a message to the terminal when closed",
  #       "object-rotate-left"
  #     )
  #     notif.should_not be(nil)
  #     if notif
  #       notif.on_close ->(notif : Void*) do
  #         notif = notif as Notify::Notification
  #         STDERR.puts notif.closed_reason
  #         STDERR.puts "Hi, if you see me it means #on_close works!"
  #       end
  #       notif.show.should be_true
  #     end
  #   end
  # end

  describe "#state" do
    it "gets the notification state" do
      man = Notify::Manager.new("CrystalNotify")
      notif = man.notify(
        "Test Notification#state",
        "..."
      )
      notif.should_not be(nil)
      if notif
        notif.state.should eq(Notify::Notification::State::Hidden)
        notif.show.should be_true
        notif.state.should eq(Notify::Notification::State::Shown)
        notif.close
        notif.state.should eq(Notify::Notification::State::Closed)
      end
    end
  end

  describe "#summary" do
    it "gets the notification summary" do
      notif_summary = "This is the summary"
      man = Notify::Manager.new("CrystalNotify")
      notif = man.notify(
        notif_summary,
        "Some content"
      )
      notif.should_not be(nil)
      if notif
        notif.summary.should eq(notif_summary)
      end
    end
  end

  describe "#summary=" do
    it "updates the notification summary" do
      man = Notify::Manager.new("CrystalNotify")
      bad_summary = "THIS IS BAD"
      notif = man.notify(
        bad_summary,
        "The summary was updated. Trust me, I'm the programmer."
      )
      notif.should_not be(nil)
      if notif
        notif.summary = "Notification update #1"
        notif.summary.should_not eq(bad_summary)
      end
    end
  end

  describe "#timeout" do
    it "gets the notification timeout" do
      man = Notify::Manager.new("CrystalNotify")
      notif = man.notify(
        "A notification",
        "Its content"
      )
      notif.should_not be(nil)
      if notif
        notif.timeout.should eq(LibNotify::Timeout::Default)
      end
    end
  end

  describe "#timeout=" do
    it "sets the notification timeout" do
      man = Notify::Manager.new("CrystalNotify")
      notif = man.notify(
        "A notification",
        "Its content"
      )
      notif.should_not be(nil)
      if notif
        notif.timeout = 10
        notif.timeout.should eq(10)
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
