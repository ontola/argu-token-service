# frozen_string_literal: true

module Actions
  class ItemsController < LinkedRails::Actions::ItemsController
    skip_before_action :check_if_registered
    before_action :authorize_action
  end
end
