class AddMessageToToken < ActiveRecord::Migration[5.0]
  def change
    add_column :tokens, :message, :text
  end
end
