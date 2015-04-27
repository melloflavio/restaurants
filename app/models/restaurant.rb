# encoding: utf-8
class Restaurant
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, :type => String
  field :address, :type => String
  field :telephone, :type => String
  field :international_telephone, :type => String #Phone in international format so wunderlist will recognize it and deep link to device s phone app
  field :website, :type => String
  field :hours, :type => String
  field :place_id, :type => String #Google's placeId
  field :latitude, :type => String
  field :longitude, :type => String
  field :location, :type => Array
  field :maps_link, :type => String
  field :sent_to_wunderlist, :type => Boolean, :default => false
  field :wunderlist_comment_id, :type => String
  field :active, :type => Boolean, :default => true #Marks if the restaurant has been deleted form wunderlist

  belongs_to :wunderlist_restaurant

  # index [[ :location, Mongo::GEO2D ]], min: -200.0, max: 200.0

  # Constructor
  def populate_from_google_places_detail(detail)
    self.name = detail["name"]
    self.address = detail["formatted_address"]
    self.telephone = detail["formatted_phone_number"]
    self.international_telephone = detail["international_phone_number"]
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

  # Sends the restaurant to wunderlist in the form of a comment in the related restaurant entry
  def send_comment_to_wunderlist
    begin
      response = Wunderlist::create_comment_on_task(self.wunderlist_restaurant.wunderlist_id.to_i, self.get_comment_string)
      self.sent_to_wunderlist = true
      self.wunderlist_comment_id = response["id"]
      self.save
    rescue Exception => ex
      puts "Error when sending restaurant #{self.name} to wunderlist: #{ex.message}"
    end

  end

  # Formats the Restaurant data to a single string which will be the body of the comment posted in wunderlist
  def get_comment_string
    phone = self.international_telephone.blank? ? self.telephone : self.international_telephone
    details = Array.new
    details << (if self.name.blank? then "Nome: - " else "Nome: #{self.name}" end)
    details << (if self.address.blank? then "Endereço: - " else "Endereço: #{self.address}" end)
    details << (if phone.blank? then "\nTelefone: - " else "\nTelefone: #{phone}" end)
    details << (if self.maps_link.blank? then "\nMaps: - " else "\nMaps: #{self.maps_link}" end)
    details << (if self.hours.blank? then "\nHorário: - " else "\nHorário:\n #{self.hours}\n" end)
    details << (if self.website.blank? then "\nWebsite: - " else "\nWebsite: #{self.website}" end)

    return details.join("\n")
  end

  # Pools wunderlist to check if comment is still present. If it  has been deleted, the restaurant should change to inactive. 
  # This represents a feedback loop where the end user can delete comments is does not believe to be related to the restaurant entry. And the system will fetch a new one in Google API
  def pool_wunderlist_status
    if self.sent_to_wunderlist && !wunderlist_comment_id.blank? #Sanity check
      active = Wunderlist::check_comment_existence(self.wunderlist_restaurant.wunderlist_id, self.wunderlist_comment_id)
      unless active #Only saves when going to inactive state, otherwise subsequent active pools would keep updating the last_updated timestamp
        self.active = false
        self.save
      end
    end
  end

end
