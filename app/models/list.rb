class List
  include Mongoid::Document
  include Mongoid::Timestamps
  load "#{Rails.root}/lib/providers/wunderlist.rb"

  field :name, :type => String
  field :wunderlist_id, :type => String

  has_many :wunderlist_restaurants

  def fetch_restaurants
    restaurants = Wunderlist::list_tasks_from_list(self.wunderlist_id)

    restaurants.each do |r|
      new_rest = WunderlistRestaurant.where(:wunderlist_id => r["id"]).first
      if !new_rest
        new_rest = WunderlistRestaurant.new
        new_rest.populate_from_wunderlist_api(r)
        new_rest.save
      end

    end
  end
end
