require "rails_helper"

RSpec.describe "POST /api/v1/messages", type: :request do
  let!(:user) { FactoryBot.create(:user) }
  let(:token) do
    Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first
  end
  let(:headers) { { "Authorization" => "Bearer #{token}" } }

  let(:valid_params) do
    {
      message: {
        phone_number: "8777804236",
        body: "Hello world",
        delivery_token: SecureRandom.uuid
      }
    }
  end

  before do
    stub_request(:post, /api.twilio.com/).to_return(
      status: 201,
      body: {
        sid: "SM1234567890abcdef",
        status: "queued"
      }.to_json,
      headers: { "Content-Type" => "application/json" }
    )

    stub_app_config(
      TWILIO_TO_PHONE_NUMBER: "+18777804236",
      TWILIO_FROM_PHONE_NUMBER: "+18885551234",
      TWILIO_ACCOUNT_SID: "test_sid",
      TWILIO_AUTH_TOKEN: "test_token"
    )
  end

  def stub_app_config(overrides = {})
    overrides.each do |key, value|
      AppConfig.send(:remove_const, key) if AppConfig.const_defined?(key)
      AppConfig.const_set(key, value)
    end
  end



  it "creates a message and returns 201" do
    post "/api/v1/messages", params: valid_params, headers: headers

    puts "RESPONSE: #{response.body}"
    puts "STATUS: #{response.status}"

    expect(response).to have_http_status(:created)

    msg = JSON.parse(response.body)["message"]
    expect(msg["id"]).to eq(Message.last.id.to_s)
    expect(msg["body"]).to eq("Hello world")
    expect(msg["status"]).to eq("pending")
  end

  it "returns 422 when body is blank" do
    post "/api/v1/messages", params: { message: valid_params[:message].merge(body: "") }, headers: headers

    expect(response).to have_http_status(422)
    json = JSON.parse(response.body)
    expect(json["errors"]).to include("Body can't be blank").or include("Missing phone number or body")
  end

  it "returns 401 without a token" do
    post "/api/v1/messages", params: valid_params
    expect(response).to have_http_status(:unauthorized)
  end
end
