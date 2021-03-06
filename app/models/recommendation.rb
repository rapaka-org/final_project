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
#  restid        :integer
#  zom_name      :string
#  zom_address   :string
#  zom_cuisine   :string
#  zom_rating    :string
#  zomlink       :string
#  votecount     :integer
#

class Recommendation < ApplicationRecord
    
    belongs_to :user, :class_name => "User", :foreign_key => "user_id"
    
    belongs_to :experience, :class_name => "Experience", :foreign_key => "experience_id"
    
    has_many :votes
    
end
