# == Schema Information
#
# Table name: experiences
#
#  id          :integer          not null, primary key
#  location    :string
#  when        :date
#  description :text
#  meal_type   :string
#  latitude    :decimal(, )
#  longitude   :decimal(, )
#  user_id     :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  entity_type :string
#  entityid    :integer
#

class Experience < ApplicationRecord
    
    belongs_to :user, :class_name => "User", :foreign_key => "user_id"
    
    has_many :recommendations
    
    
end
