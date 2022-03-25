class AddMailIdToTokens < ActiveRecord::Migration[6.0]
  def change
    add_column :tokens, :mail_identifier, :uuid
  end
end
