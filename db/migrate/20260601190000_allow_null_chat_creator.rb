class AllowNullChatCreator < ActiveRecord::Migration[8.0]
  def change
    change_column_null :chats, :creator_id, true
  end
end
