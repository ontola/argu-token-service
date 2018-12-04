class AddTypeToTokens < ActiveRecord::Migration[5.2]
  def change
    add_column :tokens, :type, :string
    Token.where(email: nil).update_all(type: 'BearerToken')
    Token.where(type: nil).update_all(type: 'EmailToken')
    change_column_null :tokens, :type, false
  end
end
