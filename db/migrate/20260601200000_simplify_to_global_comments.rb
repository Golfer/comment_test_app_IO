class SimplifyToGlobalComments < ActiveRecord::Migration[8.0]
  def up
    remove_foreign_key :comments, :chats
    remove_index :comments, name: "index_comments_on_chat_id_and_ancestry"
    remove_index :comments, name: "index_comments_on_chat_id_and_created_at"
    remove_index :comments, :chat_id
    remove_column :comments, :chat_id

    drop_table :messages
    drop_table :memberships
    drop_table :chats
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
