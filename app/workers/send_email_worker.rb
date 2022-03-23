# frozen_string_literal: true

class SendEmailWorker
  include Sidekiq::Worker

  def perform(template, email, options = {})
    recipient = {email: email}.with_indifferent_access

    Argu::API.service_api.create_email(template, recipient, **options)
  end
end
