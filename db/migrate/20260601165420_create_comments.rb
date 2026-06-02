class CreateComments < ActiveRecord::Migration[8.0]
  def change
    create_table :comments do |t|
      t.references :chat, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :body, null: false
      # Materialized path (ancestry gem). Collation "C" lets the btree index
      # serve the prefix LIKE queries ancestry uses for subtree lookups.
      t.string :ancestry, collation: "C"
      # Cached depth so depth-bounded queries don't recompute from the path.
      t.integer :ancestry_depth, null: false, default: 0

      t.timestamps
    end

    add_index :comments, :ancestry
    # Listing top-level comments in a chat, newest first.
    add_index :comments, [ :chat_id, :created_at ]
    # Subtree queries scoped to a chat.
    add_index :comments, [ :chat_id, :ancestry ]
  end
end
