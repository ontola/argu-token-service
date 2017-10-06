# frozen_string_literal: true

class VerificationsController < ActionController::Metal
  include JWTHelper

  # Used by the argu_service to verify whether the POST made in #post_membership is valid
  def show
    Token.active.find_by!(decode_token(params[:jwt]))
    self.status = 200
  rescue ActiveRecord::RecordNotFound
    self.status = 404
  end
end
