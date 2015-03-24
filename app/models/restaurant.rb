# encoding: utf-8
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
    self.hours = detail.key?("opening_hours") ? detail["opening_hours"]["weekday_text"].join("\n") : ""
    self.place_id = detail["place_id"]
    self.latitude = (detail.key?("geometry") && detail["geometry"].key?("location")) ? detail["geometry"]["location"]["lat"] : ""
    self.longitude = (detail.key?("geometry") && detail["geometry"].key?("location")) ?  detail["geometry"]["location"]["lng"] : ""
    self.location = [self.latitude, self.longitude]
    #Encoding the name. The final ) is encoded by hand as %29. If it is not encoded, wunderlist won't recognise it as part of the link
    #If used URI::Encode on the whole string, %29 gets double encoded as %2529 and it does not work properly
    self.maps_link = "http://maps.google.com/maps?daddr=#{self.latitude},#{self.longitude}%20(#{URI::encode(self.name)}%29"
  end

  def send_comment_to_wunderlist
    begin
      Wunderlist::create_comment_on_task(self.wunderlist_restaurant.wunderlist_id.to_i, self.get_comment_string)
      self.sent_to_wunderlist = true
      self.save
    rescue Exception => ex
      puts "Error when sending restaurant #{self.name} to wunderlist: #{ex.message}"
    end

  end

  def get_comment_string
    details = Array.new
    details << "Nome: #{self.name}"
    details << "Endereço: #{self.address}"
    details << "Telefone: #{self.telephone}"
    details << "Maps: #{self.maps_link}"
    details << "\nHorário:\n #{self.hours}\n"
    details << "Website: #{self.website}"

    return details.join("\n")
  end

end
