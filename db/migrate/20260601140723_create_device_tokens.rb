class CreateDeviceTokens < ActiveRecord::Migration[8.0]
  def change
    create_table :device_tokens do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :platform, null: false, default: 0
      t.string :token, null: false

      t.timestamps
    end
    add_index :device_tokens, :token, unique: true
  end
end
