class TwilioInteractor
  class ConfigurationError < StandardError; end
  STATUS_CALLBACK = "#{ENV['PUBLIC_APP_URL']}/api/v1/twilio/status_callback"

  def initialize(client: nil)
    sid = AppConfig::TWILIO_ACCOUNT_SID
    token = AppConfig::TWILIO_AUTH_TOKEN

    raise ConfigurationError, "Missing TWILIO_ACCOUNT_SID" if sid.blank?
    raise ConfigurationError, "Missing TWILIO_AUTH_TOKEN" if token.blank?

    @client = client || Twilio::REST::Client.new(sid, token)
  end


  def send_sms(to:, body:, from:, status_callback: STATUS_CALLBACK)
    raise ConfigurationError, "Missing TWILIO_PHONE_NUMBER" unless from

    message = @client.messages.create(
      from: from,
      to: to,
      body: body,
      status_callback: status_callback
    )
    message
  end
end
