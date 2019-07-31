# frozen_string_literal: true

module Actions
  class ItemsController < LinkedRails::Actions::ItemsController
    skip_before_action :check_if_registered
    before_action :authorize_action

    private

    def authorize_action
      skip_verify_policy_scoped(true)
      if parent_id_from_params.present?
        authorize parent_resource!, :show?
      else
        skip_verify_policy_authorized(true)
      end
    end

    def parent_from_params(params)
      return super unless params.key?(:token_secret)

      Token.find_by(secret: params.require(:token_secret))
    end
  end
end
