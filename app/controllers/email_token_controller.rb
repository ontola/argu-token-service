# frozen_string_literal: true

class EmailTokenController < TokensController
  def index
    render json: collection, include: inc_nested_collection
  end

  private

  def collection
    Collection.new(
      association_class: Token,
      filter: {group_id: group_id, type: 'email'},
      user_context: {},
      page: params[:page],
      pagination: true,
      parent_uri_template: :tokens_email_collection_iri,
      parent_uri_template_canonical: :tokens_email_collection_iri,
      parent_uri_template_opts: {group_id: group_id}
    )
  end

  def group_id
    @group_id ||= params.fetch(:group_id)
  end
end
