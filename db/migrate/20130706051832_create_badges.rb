class CreateBadges < ActiveRecord::Migration
  def self.up
    create_table :badges do |t|
      t.string :name
      t.string :display_name

      t.timestamps
    end

    Badge.create(:name => "newbie", :display_name => "신참")
    Badge.create(:name => "catterbox", :display_name => "수다쟁이")
    Badge.create(:name => "icebreaker", :display_name => "분위기매이커")
    Badge.create(:name => "talk_of_the_town", :display_name => "핫피플")
  end

  def self.down
    drop_table :badges
  end
end
