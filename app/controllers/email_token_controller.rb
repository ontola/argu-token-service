# frozen_string_literal: true

class EmailTokenController < TokensController
  def index
    render json: collection,
           include: [:members, :create_action, views: [:members, :create_action, views: %i[members create_action]]]
  end

  private

  def collection
    Collection.new(
      association_class: Token,
      filter: {group_id: group_id, type: 'email'},
      user_context: {},
      page: params[:page],
      pagination: true,
      url_constructor: :email_index_url,
      url_constructor_opts: group_id
    )
  end

  def group_id
    @group_id ||= params.fetch(:group_id)
  end
end
