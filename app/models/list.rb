class List
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, :type => String
  field :wunderlist_id, :type => String
  field :search_latitude, :type => String
  field :search_longitude, :type => String
  field :search_radius, :type => String
  field :place_type, :type => Array #Types os places to search for. See possible values at https://developers.google.com/places/supported_types


  has_many :wunderlist_restaurants

  def fetch_restaurants
    restaurants = Wunderlist::list_tasks_from_list(self.wunderlist_id)

    restaurants.each do |r|
      new_rest = WunderlistRestaurant.where(:wunderlist_id => r["id"]).first
      if !new_rest
        new_rest = WunderlistRestaurant.new
        new_rest.populate_from_wunderlist_api(r)
        self.wunderlist_restaurants << new_rest
        new_rest.save
      end

    end
  end
end
