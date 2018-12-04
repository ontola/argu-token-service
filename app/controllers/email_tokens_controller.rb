# frozen_string_literal: true

class EmailTokensController < TokensController
  active_response :index

  private

  def index_collection_name
    :email_token_collection
  end

  def index_includes
    {}
  end

  def group_id
    @group_id ||= params.fetch(:group_id)
  end
end
