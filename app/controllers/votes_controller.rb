class VotesController < ApplicationController

  def create
    @vote = Vote.new

    @vote.recommendation_id = params[:recommendation_id]
    @vote.user_id = current_user.id

    save_status = @vote.save

    if save_status == true
      flash.now[:status] = "Vote created successfully."
      redirect_back fallback_location: root_path
    else
      flash.now[:alert] = "Sorry! You're vote could not be saved."  
      redirect_back fallback_location: root_path
    end
  end

  def destroy
    
    @vote = Vote.find(params[:id])
    @vote.destroy
    redirect_back fallback_location: root_path
    
  end

end
