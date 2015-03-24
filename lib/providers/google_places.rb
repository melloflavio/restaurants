module GooglePlaces

  require 'rest_client'
  require 'json'

  GOOGLE_API_KEY = "INSERT GOOGLE API KEY"
  GOOGLE_API_HOST = "https://maps.googleapis.com/maps/api/place/"
  GOOGLE_API_PATH_SEARCH = "nearbysearch/json"
  GOOGLE_API_PATH_DETAIL = "details/json"

  #Radius in meters
  SEARCH_DEFAULT_RADIUS = "15000"

  # Searching for restaurants around Av. Brasil x Av Nove de Julho, São Paulo, SP
  SEARCH_DEFAULT_LAT = "-23.5767319"
  SEARCH_DEFAULT_LNG = "-46.6745702"

  # https://developers.google.com/places/webservice/search
  def self.search_for_restaurant_name (restaurant_name, search_latitude = SEARCH_DEFAULT_LAT, search_longitude = SEARCH_DEFAULT_LAT, search_radius = SEARCH_DEFAULT_RADIUS)
    url = "#{GOOGLE_API_HOST}#{GOOGLE_API_PATH_SEARCH}"
    params = Hash.new
    params["location"] = "#{SEARCH_DEFAULT_LAT},#{SEARCH_DEFAULT_LNG}"
    params["radius"] = SEARCH_DEFAULT_RADIUS
    params["types"] = "food"
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

end
