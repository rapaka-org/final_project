require 'open-uri'

class ExperiencesController < ApplicationController
  def index
    @experiences = Experience.order(when: :asc)
    @recommendations = Recommendation.all
    
    @recommendations.each do |reco|
    reco.votecount=Vote.where({:recommendation_id => reco.id}).count
    reco.save
    end
    
    @reco_one=Recommendation.order(votecount: 'desc').first
    @reco_two=Recommendation.order(votecount: 'desc').second
    @reco_third=Recommendation.order(votecount: 'desc').third
    
    @userspecific = 0
    
    render("experiences/index.html.erb")
  end
  
  def usershow
    @userspecific = 1
    @experiences = Experience.where(:user_id => params[:id])
    render("experiences/index.html.erb")
  end
  
  def new
    @experience = Experience.new
    render("experiences/new.html.erb")
  end

  def create
    @experience = Experience.new

    @experience.location = params[:location]
    @experience.when = Chronic.parse(params[:when])
    @experience.description = params[:description]
    @experience.meal_type = params[:meal_type]
    @experience.user_id = current_user.id
    
    require 'open-uri'
    
    url="https://maps.googleapis.com/maps/api/geocode/json?address="+@experience.location.gsub(" ","+")

    raw_data=open(url).read

    parsed_google=JSON.parse(raw_data)

    # if google maps does not return an error and only a single result then get latitude and longitude else error
    if(parsed_google["status"]=="OK" && parsed_google["results"][1].nil?)
    @experience.latitude = parsed_google["results"][0]["geometry"]["location"]["lat"]
    @experience.longitude = parsed_google["results"][0]["geometry"]["location"]["lng"]
    else
    flash.now[:alert] = "Please enter a valid and specific location (e.g. New York, NY)!"
    end

    # Only when google maps has pulled a latitude then proceed to work on the Zomato part of the code
    if !@experience.latitude.nil?
    
    require 'net/http'
    require 'uri'
    
    uri = URI.parse("https://developers.zomato.com/api/v2.1/geocode?lat="+@experience.latitude.to_s+"&lon="+@experience.longitude.to_s)
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

    # if Zomato has no recommendations then error
    if parsed_zomato["nearby_restaurants"].nil?
    flash.now[:alert] = "Sorry! We don't have any recommendations in that location!"  
    else
      @experience.entity_type = parsed_zomato["location"]["entity_type"]
      @experience.entityid =parsed_zomato["location"]["entity_id"]
     save_status = @experience.save
    end
    
    end
  
  # If everything worked well then show the updated message else just render back the edit page with the notice
    if save_status == true
      redirect_to("/experiences/#{@experience.id}", :notice => "Experience created successfully.")
    else
      render("experiences/new.html.erb", :alert => "Sorry! Your experience could not be saved!")
    end
  end

  def show
    @experience = Experience.find(params[:id])
    @exprecos = Recommendation.where({:experience_id => @experience.id})
    
    @exprecos.each do |reco|
    reco.votecount=Vote.where({:recommendation_id => reco.id}).count
    reco.save
    end
    
    @exprecos=@exprecos.order(votecount: 'desc')
    
    require 'net/http'
    require 'uri'
    
    uri = URI.parse("https://developers.zomato.com/api/v2.1/geocode?lat="+@experience.latitude.to_s+"&lon="+@experience.longitude.to_s)
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

    # if Zomato has no recommendations then error
    if parsed_zomato["nearby_restaurants"].nil?
    flash.now[:alert] = "Sorry! We don't have any recommendations in that location!"  
    else
      @reco_one=parsed_zomato["nearby_restaurants"][0]["restaurant"]
      @reco_two=parsed_zomato["nearby_restaurants"][1]["restaurant"]
      @reco_three=parsed_zomato["nearby_restaurants"][2]["restaurant"]
    end
    
    render("experiences/show.html.erb")
  end

  def edit
    @experience = Experience.find(params[:id])
    render("experiences/edit.html.erb")
  end

  def update
    @experience = Experience.find(params[:id])

    @experience.location = params[:location]
    @experience.when = Chronic.parse(params[:when])
    @experience.description = params[:description]
    @experience.meal_type = params[:meal_type]
    @experience.user_id = current_user.id
    
    # Only in the case of update of a record we need to clean out all the calculated fields
    @experience.latitude = nil
    @experience.longitude = nil
    @experience.entity_type = nil
    @experience.entityid = nil
    
    require 'open-uri'
    
    url="https://maps.googleapis.com/maps/api/geocode/json?address="+@experience.location.gsub(" ","+")

    raw_data=open(url).read

    parsed_google=JSON.parse(raw_data)

    # if google maps does not return an error and only a single result then get latitude and longitude else error
    if(parsed_google["status"]=="OK" && parsed_google["results"][1].nil?)
    @experience.latitude = parsed_google["results"][0]["geometry"]["location"]["lat"]
    @experience.longitude = parsed_google["results"][0]["geometry"]["location"]["lng"]
    else
    flash.now[:alert] = "Please enter a valid and specific location (e.g. New York, NY)!"
    end
    
    # Only when google maps has pulled a latitude then proceed to work on the Zomato part of the code
    if !@experience.latitude.nil?
    
    require 'net/http'
    require 'uri'
    
    uri = URI.parse("https://developers.zomato.com/api/v2.1/geocode?lat="+@experience.latitude.to_s+"&lon="+@experience.longitude.to_s)
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

    # if Zomato has no recommendations then error
    if parsed_zomato["nearby_restaurants"].nil?
    flash.now[:alert] = "Sorry! We don't have any recommendations in that location!"  
    else
      @experience.entity_type = parsed_zomato["location"]["entity_type"]
      @experience.entityid =parsed_zomato["location"]["entity_id"]
     save_status = @experience.save
    end
    
    end
  
  # If everything worked well then show the updated message else just render back the edit page with the notice
    if save_status == true
      redirect_to("/experiences/#{@experience.id}", :notice => "Experience updated successfully.")
    else
      render("experiences/edit.html.erb", :alert => "Sorry! Your experience could not be saved!")
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
