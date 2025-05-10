require "rails_helper"
require "webmock/rspec"

RSpec.describe TwilioInteractor do
  before do
    stub_request(:post, /api.twilio.com/).to_return(
      status: 201,
      body: {
        sid: "SM1234567890abcdef",
        status: "queued"
      }.to_json,
      headers: { "Content-Type" => "application/json" }
    )

    ENV["TWILIO_ACCOUNT_SID"]     = "ACxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    ENV["TWILIO_AUTH_TOKEN"]      = "auth_token"
    ENV["TWILIO_PHONE_NUMBER"]    = "+18885356542"
    ENV["TWILIO_VERIFIED_NUMBER"] = "+18777804236"
  end

  it "sends a message via Twilio API" do
    interactor = described_class.new

    response = interactor.send_sms(
      to: "+15556667777",
      body: "Test message"
    )

    expect(response.sid).to eq("SM1234567890abcdef")
    expect(WebMock).to have_requested(:post, %r{api.twilio.com}).once
  end
end
