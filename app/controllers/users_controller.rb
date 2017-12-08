class UsersController < ApplicationController
  
  def index
      
  require 'humanize'
  
  @users = User.all
  render("users/index.html.erb")
  end
  
end
  