class CreateChats < ActiveRecord::Migration[8.0]
  def change
    create_table :chats do |t|
      t.integer :kind, null: false, default: 0
      t.string :name
      t.text :description
      t.boolean :private, null: false, default: false
      t.references :creator, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
    add_index :chats, :kind
  end
end
