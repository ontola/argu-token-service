# frozen_string_literal: true

class ApplicationController < ApiController
  before_action :check_if_registered

  private

  def handle_record_not_found_error
    respond_to do |format|
      format.html do
        if action_name == 'show'
          redirect_to argu_url('/token', token: params[:secret], error: 'not_found')
        else
          render_status 404
        end
      end
      format.json_api { render json_api_error(404, 'Please provide a valid token') }
    end
  end
end
