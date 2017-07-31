class AddInviteeToTokens < ActiveRecord::Migration[5.0]
  def up
    add_column :tokens, :invitee, :string
    Token.update_all('invitee = email')
  end

  def down
    remove_column :tokens, :invitee, :string
  end
end
