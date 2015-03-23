class WunderlistRestaurant
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, :type => String
  field :wunderlist_id, :type => String
  field :list_id, :type => String

  belongs_to :list
  has_many :restaurants

  MAXIMUM_RESULTS = 3 #defines the maximum number of google results treated

  def populate_from_wunderlist_api(detail)
    self.name = detail["title"]
    self.wunderlist_id = detail["id"]
    self.list_id = detail["list_id"]
  end

  def fetch_restaurants_details_from_google
    results = GooglePlaces::search_for_restaurant_name(self.name)
    results = results[0..MAXIMUM_RESULTS]
    results.each do |r|
      new_rest_detail = WunderlistRestaurant.where(:wunderlist_id => r["place_id"]).first
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
