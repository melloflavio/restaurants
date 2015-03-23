class Restaurant
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, :type => String
  field :address, :type => String
  field :telephone, :type => String
  field :website, :type => String
  field :hours, :type => String
  field :place_id, :type => String #Google's placeId
  field :latitude, :type => String
  field :longitude, :type => String
  field :location, :type => Array
  field :maps_link, :type => String
  field :sent_to_wunderlist, :type => Boolean, :default => false

  belongs_to :wunderlist_restaurant

  # index [[ :location, Mongo::GEO2D ]], min: -200.0, max: 200.0

  def populate_from_google_places_detail(detail)
    self.name = detail["name"]
    self.address = detail["formatted_address"]
    self.telephone = detail["formatted_phone_number"]
    self.website = detail["website"]
    self.hours = detail["weekday_text"]
    self.place_id = detail["place_id"]
    self.latitude = detail["geometry"]["location"]["lat"]
    self.longitude = detail["geometry"]["location"]["lng"]
    self.location = [self.latitude, self.longitude]
    self.maps_link = "http://maps.google.com/maps?daddr=#{self.latitude},#{self.longitude} (#{self.name})"
  end


end
