class AddProfileIRIToTokens < ActiveRecord::Migration[5.0]
  def change
    add_column :tokens, :profile_iri, :string
  end
end
