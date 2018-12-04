# frozen_string_literal: true

class BearerTokensController < TokensController
  active_response :index

  private

  def index_collection_name
    :bearer_token_collection
  end

  def group_id
    @group_id ||= params.fetch(:group_id)
  end
end
