# frozen_string_literal: true

class EmailTokenController < TokensController
  active_response :index

  private

  def index_collection
    @index_collection ||= ::Collection.new(
      association_class: Token,
      filter: {group_id: group_id, type: 'email'},
      user_context: {},
      parent_uri_template: :tokens_email_collection_iri,
      parent_uri_template_canonical: :tokens_email_collection_iri,
      parent_uri_template_opts: {group_id: group_id}
    )
  end

  def index_includes
    {}
  end

  def group_id
    @group_id ||= params.fetch(:group_id)
  end
end
