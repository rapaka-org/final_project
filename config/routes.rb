Rails.application.routes.draw do

  root 'experiences#index'
  
  # Routes for the Experience resource:
  # CREATE
  get "/experiences/new", :controller => "experiences", :action => "new"
  post "/create_experience", :controller => "experiences", :action => "create"

  # READ
  get "/experiences", :controller => "experiences", :action => "index"
  get "/experiences/:id", :controller => "experiences", :action => "show"

  # UPDATE
  get "/experiences/:id/edit", :controller => "experiences", :action => "edit"
  post "/update_experience/:id", :controller => "experiences", :action => "update"

  # DELETE
  get "/delete_experience/:id", :controller => "experiences", :action => "destroy"
  #------------------------------

  devise_for :users
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  

  
end
