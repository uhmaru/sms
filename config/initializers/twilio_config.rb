module AppConfig
  TWILIO_ACCOUNT_SID = ENV.fetch("TWILIO_ACCOUNT_SID") do
    raise "Missing required ENV var: TWILIO_ACCOUNT_SID"
  end

  TWILIO_AUTH_TOKEN = ENV.fetch("TWILIO_AUTH_TOKEN") do
    raise "Missing required ENV var: TWILIO_AUTH_TOKEN"
  end

  TWILIO_TO_PHONE_NUMBER = ENV.fetch("TWILIO_TO_PHONE_NUMBER") do
    raise "Missing required ENV var: TWILIO_TO_PHONE_NUMBER"
  end

  TWILIO_FROM_PHONE_NUMBER = ENV.fetch("TWILIO_FROM_PHONE_NUMBER") do
    raise "Missing required ENV var: TWILIO_FROM_PHONE_NUMBER"
  end
end
