class AddRedirectUrlToTokens < ActiveRecord::Migration[5.0]
  def change
    add_column :tokens, :redirect_url, :string
  end
end
