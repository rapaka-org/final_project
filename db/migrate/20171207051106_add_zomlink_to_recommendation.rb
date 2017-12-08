class AddZomlinkToRecommendation < ActiveRecord::Migration[5.1]
  def change
    add_column :recommendations, :zomlink, :string
  end
end
