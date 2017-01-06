# frozen_string_literal: true
class ApplicationController < ServiceBase::ApiController
  before_action :check_if_registered

  private

  def client_token
    request.cookie_jar.encrypted['client_token']
  end

  def handle_record_not_found_error
    respond_to do |format|
      format.html do
        send_file File.expand_path('../../../public/404.html', __FILE__), disposition: :inline, status: 404
      end
      format.json { render json_api_error(404, 'Please provide a valid token') }
    end
  end
end
