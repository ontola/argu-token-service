class RenameProfileIRIToActorIRI < ActiveRecord::Migration[5.0]
  def change
    rename_column :tokens, :profile_iri, :actor_iri
  end
end
