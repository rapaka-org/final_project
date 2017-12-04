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
    @experience.user_id = current_user.id
    
    require 'open-uri'
    
    url="https://maps.googleapis.com/maps/api/geocode/json?address="+@experience.location.gsub(" ","+")

    raw_data=open(url).read

    parsed_data=JSON.parse(raw_data)
    
    if parsed_data["status"]=="OK"
    @experience.latitude = parsed_data["results"][0]["geometry"]["location"]["lat"]
    @experience.longitude = parsed_data["results"][0]["geometry"]["location"]["lng"]
    else
    flash.now[:alert] = "Please enter a valid location!"
    end
    
    require 'net/http'
    require 'uri'
    
    uri = URI.parse("https://developers.zomato.com/api/v2.1/locations?query="+@experience.location+"&lat="+@experience.latitude.to_s+"&lon="+@experience.longitude.to_s+"&count=1")
    request = Net::HTTP::Get.new(uri)
    request["Accept"] = "application/json"
    request["User-Key"] = "a8892401fb096927db5ab354ed3f631a"
    
    req_options = {
      use_ssl: uri.scheme == "https",
    }
    
    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end
    
    parsed_zomato=JSON.parse(response.body)
    
    if parsed_zomato["location_suggestions"][0].nil?
    flash.now[:alert] = "Sorry! We don't have any recommendations in that location!"  
    else
      @experience.entity_type = parsed_zomato["location_suggestions"][0]["entity_type"]
      @experience.entityid =parsed_zomato["location_suggestions"][0]["entity_id"]
     save_status = @experience.save
    end
    
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
    @experience.user_id = current_user.id
    
    require 'open-uri'
    
    url="https://maps.googleapis.com/maps/api/geocode/json?address="+@experience.location.gsub(" ","+")

    raw_data=open(url).read

    parsed_data=JSON.parse(raw_data)
    
    if parsed_data["status"]=="OK"
    @experience.latitude = parsed_data["results"][0]["geometry"]["location"]["lat"]
    @experience.longitude = parsed_data["results"][0]["geometry"]["location"]["lng"]
    else
    flash.now[:alert] = "Please enter a valid location!"
    end
    
    require 'net/http'
    require 'uri'
    
    uri = URI.parse("https://developers.zomato.com/api/v2.1/locations?query="+@experience.location+"&lat="+@experience.latitude.to_s+"&lon="+@experience.longitude.to_s+"&count=1")
    request = Net::HTTP::Get.new(uri)
    request["Accept"] = "application/json"
    request["User-Key"] = "a8892401fb096927db5ab354ed3f631a"
    
    req_options = {
      use_ssl: uri.scheme == "https",
    }
    
    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end
    
    parsed_zomato=JSON.parse(response.body)
    
    if parsed_zomato["location_suggestions"][0].nil?
    flash.now[:alert] = "Sorry! We don't have any recommendations in that location!"  
    else
      @experience.entity_type = parsed_zomato["location_suggestions"][0]["entity_type"]
      @experience.entityid =parsed_zomato["location_suggestions"][0]["entity_id"]
     save_status = @experience.save
    end

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
