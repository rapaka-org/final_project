require 'open-uri'

class RecommendationsController < ApplicationController
  def index
    @userspecific = 0
    @recommendations = Recommendation.all
    render("recommendations/index.html.erb")
  end
  
  def usershow
    @userspecific = 1
    @recommendations = Recommendation.where(:user_id => params[:id])
    render("recommendations/index.html.erb")
  end

  def show
    @recommendation = Recommendation.find(params[:id])

    render("recommendations/show.html.erb")
  end

  def new
    @recommendation = Recommendation.new
    @experience=Experience.find(params[:id])
    render("recommendations/new.html.erb")
  end

  def create
    @recommendation = Recommendation.new

    @recommendation.name = params[:name]
    @recommendation.address = params[:address]
    @recommendation.experience_id = params[:experience_id]
    @recommendation.user_id = current_user.id
    
    require 'open-uri'
    
    url="https://maps.googleapis.com/maps/api/geocode/json?address="+@recommendation.address.gsub(" ","+")

    raw_data=open(url).read

    parsed_google=JSON.parse(raw_data)

    # if google maps does not return an error and only a single result then get latitude and longitude else error
    if(parsed_google["status"]=="OK" && parsed_google["results"][1].nil?)
    @recommendation.latitude = parsed_google["results"][0]["geometry"]["location"]["lat"]
    @recommendation.longitude = parsed_google["results"][0]["geometry"]["location"]["lng"]
    else
    flash.now[:alert] = "Please enter a valid and specific location (e.g. New York, NY)!"
    end

    # Only when google maps has pulled a latitude then proceed to work on the Zomato part of the code
    if !@recommendation.latitude.nil?

    require 'net/http'
    require 'uri'
    
    uri = URI.parse("https://developers.zomato.com/api/v2.1/search?q="+@recommendation.name+"&count=1&lat="+@recommendation.latitude.to_s+"&lon="+@recommendation.longitude.to_s+"&sort=real_distance")
  
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
    if parsed_zomato["restaurants"].nil?
    flash.now[:alert] = "Sorry! We don't have any recommendations in that location!"  
    else
    @recommendation.restid = parsed_zomato["restaurants"][0]["restaurant"]["id"]
    @recommendation.zom_name = parsed_zomato["restaurants"][0]["restaurant"]["name"]
    @recommendation.zom_address = parsed_zomato["restaurants"][0]["restaurant"]["location"]["address"]
    @recommendation.zom_cuisine = parsed_zomato["restaurants"][0]["restaurant"]["cuisines"]
    @recommendation.zom_rating = parsed_zomato["restaurants"][0]["restaurant"]["user_rating"]["rating_text"]
    @recommendation.zom_rating = parsed_zomato["restaurants"][0]["restaurant"]["url"]
    end

    end
    
    if Recommendation.exists?(:restid => @recommendation.restid)
        vote = Vote.new
        vote.recommendation_id = Recommendation.find_by({ :restid => @recommendation.restid }).id
        vote.user_id = current_user.id
        vote.save
    else 
        save_status = @recommendation.save
    end

    if save_status == true
      redirect_to("/recommendations/#{@recommendation.id}", :notice => "Recommendation created successfully.")
    else
      redirect_to("/experiences/#{@recommendation.experience_id}", :alert => "A user has already recommended this location. Your vote has been logged!")
    end
  end

  def edit
    @recommendation = Recommendation.find(params[:id])

    render("recommendations/edit.html.erb")
  end

  def update
    @recommendation = Recommendation.find(params[:id])

    @recommendation.name = params[:name]
    @recommendation.address = params[:address]
    @recommendation.latitude = nil
    @recommendation.longitude = nil
    @recommendation.restid = nil
    @recommendation.zom_name = nil
    @recommendation.zom_address = nil
    @recommendation.zom_cuisine = nil
    @recommendation.zom_rating = nil
    @recommendation.zom_rating = nil
    @recommendation.experience_id = params[:experience_id]
    @recommendation.user_id = current_user.id
    
    require 'open-uri'
    
    url="https://maps.googleapis.com/maps/api/geocode/json?address="+@recommendation.address.gsub(" ","+")

    raw_data=open(url).read

    parsed_google=JSON.parse(raw_data)

    # if google maps does not return an error and only a single result then get latitude and longitude else error
    if(parsed_google["status"]=="OK" && parsed_google["results"][1].nil?)
    @recommendation.latitude = parsed_google["results"][0]["geometry"]["location"]["lat"]
    @recommendation.longitude = parsed_google["results"][0]["geometry"]["location"]["lng"]
    else
    flash.now[:alert] = "Please enter a valid and specific location (e.g. New York, NY)!"
    end

    # Only when google maps has pulled a latitude then proceed to work on the Zomato part of the code
    if !@recommendation.latitude.nil?

    require 'net/http'
    require 'uri'
    
    uri = URI.parse("https://developers.zomato.com/api/v2.1/search?q="+@recommendation.name+"&count=1&lat="+@recommendation.latitude.to_s+"&lon="+@recommendation.longitude.to_s+"&sort=real_distance")
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
    if parsed_zomato["restaurants"].nil?
    flash.now[:alert] = "Sorry! We don't have any recommendations in that location!"  
    else
      @recommendation.restid = parsed_zomato["restaurants"][0]["restaurant"]["id"]
      @recommendation.zom_name = parsed_zomato["restaurants"][0]["restaurant"]["name"]
      @recommendation.zom_address = parsed_zomato["restaurants"][0]["restaurant"]["location"]["address"]
      @recommendation.zom_cuisine = parsed_zomato["restaurants"][0]["restaurant"]["cuisines"]
      @recommendation.zom_rating = parsed_zomato["restaurants"][0]["restaurant"]["user_rating"]["rating_text"]
      @recommendation.zom_rating = parsed_zomato["restaurants"][0]["restaurant"]["url"]
    end

    end

    if Recommendation.exists?(:restid => @recommendation.restid)
        vote = Vote.new
        vote.recommendation_id = Recommendation.find_by({ :restid => @recommendation.restid }).id
        vote.user_id = current_user.id
        vote.save
    else 
        save_status = @recommendation.save
    end

    if save_status == true
      redirect_to("/recommendations/#{@recommendation.id}", :notice => "Recommendation created successfully.")
    else
      redirect_to("/experiences/#{@recommendation.experience_id}", :alert => "A user has already recommended this location. Your vote has been logged!")
    end
    
  end

  def destroy
    @recommendation = Recommendation.find(params[:id])

    @recommendation.destroy

    if URI(request.referer).path == "/recommendations/#{@recommendation.id}"
      redirect_to("/", :notice => "Recommendation deleted.")
    else
      redirect_back(:fallback_location => "/", :notice => "Recommendation deleted.")
    end
  end
end
