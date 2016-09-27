# frozen_string_literal: true
class ApplicationController < ServiceBase::ApiController
  before_action :check_if_registered

  private

  def client_token
    request.cookie_jar.encrypted['client_token']
  end
end
