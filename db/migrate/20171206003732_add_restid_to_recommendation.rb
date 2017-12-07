class AddRestidToRecommendation < ActiveRecord::Migration[5.1]
  def change
    add_column :recommendations, :restid, :integer
  end
end
