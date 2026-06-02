class AddChatCreatedAtIndexToMessages < ActiveRecord::Migration[8.0]
  def change
    # Loading a chat's messages in chronological order is the hot path.
    add_index :messages, [ :chat_id, :created_at ]
  end
end
