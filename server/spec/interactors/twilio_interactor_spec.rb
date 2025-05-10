require 'rails_helper'

RSpec.describe TwilioInteractor do
  let(:twilio_client)       { mock('Twilio::REST::Client') }
  let(:twilio_messages)     { mock('Twilio::REST::Api::V2010::AccountContext::MessageList') }
  let(:twilio_response)     { stub('Twilio::Message', sid: 'SM1234567890abcdef', status: 'queued') }

  before do
    ENV['TWILIO_ACCOUNT_SID'] = 'ACxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
    ENV['TWILIO_AUTH_TOKEN'] = 'auth_token'
    ENV['TWILIO_PHONE_NUMBER'] = '+18885356542'
    ENV['TWILIO_VERIFIED_NUMBER'] = '+18777804236'

    Twilio::REST::Client.stubs(:new).returns(twilio_client)
    twilio_client.stubs(:messages).returns(twilio_messages)
  end

  describe '#send_sms' do
    it 'sends an SMS and returns a response with a SID' do
      twilio_messages.expects(:create).with(
        from: '+18885356542',
        to: '+18777804236',
        body: 'Test message',
        status_callback: TwilioInteractor::STATUS_CALLBACK
      ).returns(twilio_response)

      response = described_class.new.send_sms(
        from: '+18885356542',
        to: '+18777804236',
        body: 'Test message',
        status_callback: TwilioInteractor::STATUS_CALLBACK
      )

      expect(response.sid).to eq('SM1234567890abcdef')
    end
  end
end
