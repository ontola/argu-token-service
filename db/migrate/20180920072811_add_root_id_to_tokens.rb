class AddRootIdToTokens < ActiveRecord::Migration[5.0]
  include UriTemplateHelper

  def change
    enable_extension 'uuid-ossp'

    add_column :tokens, :root_id, :uuid
    add_index :tokens, :root_id
    Token.pluck(:group_id).uniq.each do |group_id|
      group =
        ActiveResourceModel.find(:one, from: expand_uri_template(:groups_iri, id: group_id, include_hostname: true))
      root_id = group.organization.canonical_iri.split('edges/').last
      Token.where(group_id: group_id).update_all(root_id: root_id)
    end
    change_column_null :tokens, :root_id, false
  end
end
