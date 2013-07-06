class AddScoreAndLevelToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :score, :integer, default: 0
    add_column :users, :level_id, :integer
  end

  def self.down
    remove_column :users, :level_id
    remove_column :users, :score
  end
end
