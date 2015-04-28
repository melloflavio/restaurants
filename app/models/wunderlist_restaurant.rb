class WunderlistRestaurant
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, :type => String
  field :wunderlist_id, :type => String
  field :list_id, :type => String

  belongs_to :list
  has_many :restaurants

  MAXIMUM_RESTAURANTS = 1 #defines the maximum number of active Restaurants related

  # Constructor
  def populate_from_wunderlist_api(detail)
    self.name = detail["title"]
    self.wunderlist_id = detail["id"]
    self.list_id = detail["list_id"]
  end

  # Fetches a restaurant from Google's api using the restaurant name and other list data such as Lat/Lng
  def fetch_restaurants_details_from_google
  if self.restaurants.where(:active => true).count < MAXIMUM_RESTAURANTS
      results = GooglePlaces::search_for_restaurant_name(self.name, search_latitude: self.list.search_latitude, search_longitude: self.list.search_longitude, search_radius: self.list.search_radius, search_types: self.list.place_types)
      results.each do |r|
        new_rest_detail = Restaurant.where(:place_id => r["place_id"]).first
        if !new_rest_detail
          new_rest_detail = Restaurant.new
          detail = GooglePlaces::search_for_restaurant_detail(r["place_id"])
          new_rest_detail.populate_from_google_places_detail(detail)
          self.restaurants << new_rest_detail
          new_rest_detail.save
          break
        end
      end
    end
  end

  def pool_wunderlist_for_name_change
    # Only pools for name change unsuccessful restaurant searches
    if self.restaurants.where(:active => true).count < MAXIMUM_RESTAURANTS
      detail = Wunderlist::get_task_detail(self.wunderlist_id)
      if !detail["title"].blank? && detail["title"] != self.name
        self.name = detail["title"]
        self.save
      end
    end
  end

end
