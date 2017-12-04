class CreateExperiences < ActiveRecord::Migration[5.0]
  def change
    create_table :experiences do |t|
      t.string :location
      t.date :when
      t.text :description
      t.string :meal_type
      t.decimal :latitude
      t.decimal :longitude
      t.integer :user_id

      t.timestamps

    end
  end
end
