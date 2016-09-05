class RestaurantsController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception


  def all_rests
    rests = []
    Restaurant.where(:active => true, :wunderlist_completed => false).each do |r|
      rests << r.to_dto
    end

    # return rests.to_json
    render json: rests
  end

end