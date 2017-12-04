class AddEntityTypeToExperiences < ActiveRecord::Migration[5.1]
  def change
    
    add_column :experiences, :entity_type, :string
    
  end
end
