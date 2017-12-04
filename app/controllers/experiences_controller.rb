require 'open-uri'

class ExperiencesController < ApplicationController
  def index
    @experiences = Experience.all

    render("experiences/index.html.erb")
  end

  def show
    @experience = Experience.find(params[:id])

    render("experiences/show.html.erb")
  end

  def new
    @experience = Experience.new

    render("experiences/new.html.erb")
  end

  def create
    @experience = Experience.new

    @experience.location = params[:location]
    @experience.when = params[:when]
    @experience.description = params[:description]
    @experience.meal_type = params[:meal_type]
    
    require 'open-uri'
    
    url="https://maps.googleapis.com/maps/api/geocode/json?address="+@experience.location.gsub(" ","+")

    raw_data=open(url).read

    parsed_data=JSON.parse(raw_data)

    @experience.latitude = parsed_data["results"][0]["geometry"]["location"]["lat"]

    @experience.longitude = parsed_data["results"][0]["geometry"]["location"]["lng"]

    @experience.user_id = current_user.id

    save_status = @experience.save

    if save_status == true
      redirect_to("/experiences/#{@experience.id}", :notice => "Experience created successfully.")
    else
      render("experiences/new.html.erb")
    end
  end

  def edit
    @experience = Experience.find(params[:id])

    render("experiences/edit.html.erb")
  end

  def update
    @experience = Experience.find(params[:id])

    @experience.location = params[:location]
    @experience.when = params[:when]
    @experience.description = params[:description]
    @experience.meal_type = params[:meal_type]
    @experience.latitude = params[:latitude]
    @experience.longitude = params[:longitude]
    @experience.user_id = params[:user_id]

    save_status = @experience.save

    if save_status == true
      redirect_to("/experiences/#{@experience.id}", :notice => "Experience updated successfully.")
    else
      render("experiences/edit.html.erb")
    end
  end

  def destroy
    @experience = Experience.find(params[:id])

    @experience.destroy

    if URI(request.referer).path == "/experiences/#{@experience.id}"
      redirect_to("/", :notice => "Experience deleted.")
    else
      redirect_back(:fallback_location => "/", :notice => "Experience deleted.")
    end
  end
end
