# == Schema Information
#
# Table name: recommendations
#
#  id            :integer          not null, primary key
#  name          :string
#  address       :string
#  latitude      :decimal(, )
#  longitude     :decimal(, )
#  experience_id :integer
#  user_id       :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class Recommendation < ApplicationRecord
    
    belongs_to :user, :class_name => "User", :foreign_key => "user_id"
    
    belongs_to :experience, :class_name => "Experience", :foreign_key => "experience_id"
    
end
