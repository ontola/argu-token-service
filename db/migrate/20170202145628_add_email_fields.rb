class AddEmailFields < ActiveRecord::Migration[5.0]
  def change
    add_column :tokens, :email, :string
    add_column :tokens, :send_mail, :boolean
    add_column :tokens, :last_used_at, :datetime
  end
end
