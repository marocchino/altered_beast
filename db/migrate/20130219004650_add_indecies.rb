class AddIndecies < ActiveRecord::Migration
  def self.up
    add_index :levels, :required_score
    add_index :topics, :last_user_id
    add_index :topics, :site_id
    add_index :topics, :user_id
    add_index :posts, :site_id
    add_index :monitorships, :topic_id
    add_index :monitorships, :user_id
    add_index :moderatorships, :user_id
    add_index :moderatorships, :forum_id
  end

  def self.down
    remove_index :levels, :required_score
    remove_index :topics, :last_user_id
    remove_index :topics, :site_id
    remove_index :topics, :user_id
    remove_index :posts, :site_id
    remove_index :monitorships, :topic_id
    remove_index :monitorships, :user_id
    remove_index :moderatorships, :user_id
    remove_index :moderatorships, :forum_id
  end
end
