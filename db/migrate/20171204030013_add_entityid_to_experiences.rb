class AddEntityidToExperiences < ActiveRecord::Migration[5.1]
  def change
    add_column :experiences, :entityid, :integer
  end
end
