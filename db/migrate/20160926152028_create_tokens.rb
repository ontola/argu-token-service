class CreateTokens < ActiveRecord::Migration[5.0]
  def self.up
    create_table :tokens do |t|
      t.string :secret, null: false
      t.integer :group_id, null: false
      t.integer :usages, default: 0, null: false
      t.integer :max_usages
      t.datetime :expires_at
      t.datetime :retracted_at
      t.timestamps
      t.index [:expires_at, :retracted_at, :group_id]
      t.index [:secret]
    end
  end

  def self.down
    drop_table :tokens
  end
end
