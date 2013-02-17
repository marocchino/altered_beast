# encoding: utf-8
class CreateLevels < ActiveRecord::Migration
  def self.up
    create_table :levels do |t|
      t.integer :number
      t.string :display_name
      t.integer :required_score, default: 0

      t.timestamps
    end
    Level.create number: 1, display_name: "새내기", required_score: 0
    Level.create number: 2, display_name: "초보", required_score: 50
    Level.create number: 3, display_name: "샌님", required_score: 100
    Level.create number: 4, display_name: "학습자", required_score: 200
    Level.create number: 5, display_name: "제안자", required_score: 350
    Level.create number: 6, display_name: "만물박사", required_score: 600
    Level.create number: 7, display_name: "전문가", required_score: 1000
    Level.create number: 8, display_name: "지젼", required_score: 2000
  end

  def self.down
    drop_table :levels
  end
end
