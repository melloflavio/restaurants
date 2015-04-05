module GooglePlaces

  require 'rest_client'
  require 'json'

  GOOGLE_API_KEY = ENV['GOOGLE_API_KEY']
  GOOGLE_API_HOST = "https://maps.googleapis.com/maps/api/place/"
  GOOGLE_API_PATH_SEARCH = "nearbysearch/json"
  GOOGLE_API_PATH_DETAIL = "details/json"

  #Radius in meters
  DEFAULT_RADIUS = "15000"

  # Searching for restaurants around Av. Brasil x Av Nove de Julho, São Paulo, SP
  DEFAULT_LAT = "-23.5767319"
  DEFAULT_LNG = "-46.6745702"
  DEFAULT_TYPES = ["restaurant"]


  # https://developers.google.com/places/webservice/search
  def self.search_for_restaurant_name (restaurant_name, options = {})
    options = self.populate_search_defaults(options)
    url = "#{GOOGLE_API_HOST}#{GOOGLE_API_PATH_SEARCH}"
    params = Hash.new
    params["location"] = "#{options[:search_latitude]},#{options[:search_longitude]}"
    params["radius"] = options[:search_radius]
    params["types"] = options[:search_types].join("|")
    params["rankby"] = "prominence" #The search is for restaurants in a large area. Better to rank by prominence than radius
    params["name"] = restaurant_name
    params["key"] = GOOGLE_API_KEY
    params["language"] = "pt-BR"

    response = RestClient.get url, {:params => params}
    parsed = JSON.parse(response)

    return parsed["results"]
  end

  # https://developers.google.com/places/webservice/search
  def self.search_for_restaurant_detail (restaurant_id)
    url = "#{GOOGLE_API_HOST}#{GOOGLE_API_PATH_DETAIL}"
    params = Hash.new
    params["placeid"] = restaurant_id
    params["key"] = GOOGLE_API_KEY
    params["language"] = "pt-BR"

    response = RestClient.get url, {:params => params}
    parsed = JSON.parse(response)

    return parsed["result"]
  end

  def self.populate_search_defaults(options = {})
     options[:search_latitude] ||= DEFAULT_LAT 
     options[:search_longitude] ||= DEFAULT_LNG
     options[:search_radius] ||= DEFAULT_RADIUS
     options[:search_types] ||= DEFAULT_TYPES

     return options
  end

end
