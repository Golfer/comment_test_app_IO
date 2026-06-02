class CreateMemberships < ActiveRecord::Migration[8.0]
  def change
    create_table :memberships do |t|
      t.references :user, null: false, foreign_key: true
      t.references :chat, null: false, foreign_key: true
      t.integer :role, null: false, default: 0
      t.datetime :last_read_at

      t.timestamps
    end
    add_index :memberships, [ :user_id, :chat_id ], unique: true
  end
end
