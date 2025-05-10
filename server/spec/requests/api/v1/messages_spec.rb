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
        phone_number: "+15555555555",
        body: "Hello world",
        delivery_token: SecureRandom.uuid
      }
    }
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
