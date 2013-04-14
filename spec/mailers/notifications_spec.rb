require "spec_helper"

describe Notifications do
  describe "recieved_message" do
    let(:mail) { Notifications.recieved_message }

    it "renders the headers" do
      mail.subject.should eq("Recieved message")
      mail.to.should eq(["to@example.org"])
      mail.from.should eq(["from@example.com"])
    end

    it "renders the body" do
      mail.body.encoded.should match("Hi")
    end
  end

end
