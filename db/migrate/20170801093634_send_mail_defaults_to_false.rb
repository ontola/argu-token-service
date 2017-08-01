class SendMailDefaultsToFalse < ActiveRecord::Migration[5.0]
  def change
    Token.where(send_mail: nil).update_all(send_mail: false)
    change_column :tokens, :send_mail, :boolean, default: false, null: false
  end
end
