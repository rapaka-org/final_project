class VotesController < ApplicationController
  def index
    @votes = Vote.all

    render("votes/index.html.erb")
  end

  def show
    @vote = Vote.find(params[:id])

    render("votes/show.html.erb")
  end

  def new
    @vote = Vote.new
    
    render("votes/new.html.erb")
  end

  def create
    @vote = Vote.new

    @vote.recommendation_id = params[:recommendation_id]
    @vote.user_id = current_user.id

    save_status = @vote.save

    if save_status == true
      redirect_to("/votes/#{@vote.id}", :notice => "Vote created successfully.")
    else
      render("votes/new.html.erb")
    end
  end

  def edit
    @vote = Vote.find(params[:id])

    render("votes/edit.html.erb")
  end

  def update
    @vote = Vote.find(params[:id])

    @vote.recommendation_id = params[:recommendation_id]
    @vote.user_id = params[:user_id]

    save_status = @vote.save

    if save_status == true
      redirect_to("/votes/#{@vote.id}", :notice => "Vote updated successfully.")
    else
      render("votes/edit.html.erb")
    end
  end

  def destroy
    @vote = Vote.find(params[:id])

    @vote.destroy

    if URI(request.referer).path == "/votes/#{@vote.id}"
      redirect_to("/", :notice => "Vote deleted.")
    else
      redirect_back(:fallback_location => "/", :notice => "Vote deleted.")
    end
  end
end
