# frozen_string_literal: true

class ApplicationController < ApiController
  include ActiveResponse::Controller
  include ActiveResponseHelper

  private

  def handle_record_not_found_html(_e)
    return super unless action_name == 'show'
    redirect_to argu_url('/token', token: params[:secret], error: 'not_found')
  end
end
