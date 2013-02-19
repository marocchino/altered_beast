class Level < ActiveRecord::Base

  def self.level_for_score(score)
    where(["required_score <= ?", score]).order("required_score DESC").first
  end
end