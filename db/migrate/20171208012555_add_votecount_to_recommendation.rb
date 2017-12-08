class AddVotecountToRecommendation < ActiveRecord::Migration[5.1]
  def change
    add_column :recommendations, :votecount, :integer
  end
end
