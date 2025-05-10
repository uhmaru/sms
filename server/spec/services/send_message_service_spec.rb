# frozen_string_literal: true

require "rails_helper"
require "sidekiq/testing"

RSpec.describe SendMessageService do
  let(:user) { FactoryBot.create(:user) }
  let(:recipient_number) { "+15555555555" }
  let(:body) { "Hello world" }
  let(:delivery_token) { SecureRandom.uuid }

  let(:job_class_spy) do
    Class.new do
      cattr_accessor :performed_with
      self.performed_with = []

      def self.perform_async(message_id)
        self.performed_with << message_id
      end
    end
  end

  subject(:send_message) do
    described_class.new(
      user: user,
      recipient_number: recipient_number,
      body: body,
      conversation_repo: ConversationRepository.new,
      delivery_token: delivery_token,
      job_class: job_class_spy
    )
  end

  describe "#call" do
    context "when the message is valid" do

      before do
        Rails.configuration.x.stubs(:allowed_sms_recipients).returns([recipient_number])
      end

      it "creates the conversation, persists the message, and calls the job class" do
        expect {
          result = send_message.call
          expect(result).to be_success
          expect(result.data).to be_a(Message)
        }.to change(Message, :count).by(1)
                                    .and change(Conversation, :count).by(1)

        message = Message.last
        expect(message.user).to eq(user)
        expect(message.recipient_number).to eq(recipient_number)

        expect(job_class_spy.performed_with).to include(message.id.to_s)
      end
    end

    context "when the message is invalid" do
      let(:body) { "" }

      before do
        Rails.configuration.x.stubs(:allowed_sms_recipients).returns([recipient_number])
      end

      it "returns a failure and does not call the job class" do
        expect {
          send_message.call
        }.to raise_error(StandardError, "Missing phone number or body")

        expect(job_class_spy.performed_with).to be_empty
      end
    end

    context "when the phone number is not allowed" do
      before do
        Rails.configuration.x.stubs(:allowed_sms_recipients).returns([])
      end

      it "raises an error and does not call the job class" do
        expect {
          send_message.call
        }.to raise_error(StandardError, "Recipient number not allowed in this environment")

        expect(job_class_spy.performed_with).to be_empty
      end
    end

  end
end
