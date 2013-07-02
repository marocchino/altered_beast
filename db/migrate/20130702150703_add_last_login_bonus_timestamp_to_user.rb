class AddLastLoginBonusTimestampToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :last_login_bonus_awarded_at, :datetime
  end

  def self.down
    remove_column :users, :last_login_bonus_awarded_at, :datetime
  end
end
