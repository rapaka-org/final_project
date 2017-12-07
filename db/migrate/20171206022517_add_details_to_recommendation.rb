class AddDetailsToRecommendation < ActiveRecord::Migration[5.1]
  def change
    add_column :recommendations, :zom_name, :string
    add_column :recommendations, :zom_address, :string
    add_column :recommendations, :zom_cuisine, :string
    add_column :recommendations, :zom_rating, :string
  end
end
