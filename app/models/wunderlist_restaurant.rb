class WunderlistRestaurant
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, :type => String
  field :wunderlist_id, :type => String
  field :list_id, :type => String

  belongs_to :list
  has_many :restaurants

  MAXIMUM_RESULTS = 1 #defines the maximum number of active Restaurants related

  def populate_from_wunderlist_api(detail)
    self.name = detail["title"]
    self.wunderlist_id = detail["id"]
    self.list_id = detail["list_id"]
  end

  def fetch_restaurants_details_from_google
	if self.restaurants.where(:active => true).count < MAXIMUM_RESULTS
      results = GooglePlaces::search_for_restaurant_name(self.name, search_latitude: self.list.search_latitude, search_longitude: self.list.search_longitude, search_radius: self.list.search_radius, search_types: self.list.place_types)
      results.each do |r|
        new_rest_detail = Restaurant.where(:place_id => r["place_id"]).first
        if !new_rest_detail
          new_rest_detail = Restaurant.new
          detail = GooglePlaces::search_for_restaurant_detail(r["place_id"])
          new_rest_detail.populate_from_google_places_detail(detail)
          self.restaurants << new_rest_detail
          new_rest_detail.save
        end
      end
    end
  end

end
