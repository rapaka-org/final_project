# == Schema Information
#
# Table name: votes
#
#  id                :integer          not null, primary key
#  recommendation_id :integer
#  user_id           :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class Vote < ApplicationRecord
    
    belongs_to :user, :class_name => "User", :foreign_key => "user_id"
    
    belongs_to :recommendation, :class_name => "Recommendation", :foreign_key => "recommendation_id"
    
    
end
