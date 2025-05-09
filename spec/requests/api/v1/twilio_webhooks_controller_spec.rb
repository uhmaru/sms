require "rails_helper"

RSpec.describe Api::V1::TwilioWebhooksController, type: :request do
  describe "POST /api/v1/twilio/status_callback" do
    let(:twilio_sid) { "SM123456" }
    let!(:message) { FactoryBot.create(:message, status: "sent", twilio_sid: twilio_sid) }

    it "updates the message status if MessageSid matches" do
      post "/api/v1/twilio/status_callback", params: {
        "MessageSid" => twilio_sid,
        "MessageStatus" => "delivered"
      }

      expect(Message.where(twilio_sid: twilio_sid).count).to eq(1)
      expect(response).to have_http_status(:ok)
      expect(message.reload&.status).to eq("delivered")
    end

    it "returns not found even if MessageSid does not match any message" do
      post "/api/v1/twilio/status_callback", params: {
        "MessageSid" => "SM_UNKNOWN",
        "MessageStatus" => "failed"
      }

      expect(response).to have_http_status(:not_found)
    end
  end
end
