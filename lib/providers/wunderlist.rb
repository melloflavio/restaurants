module Wunderlist

  require 'rest_client'
  require 'json'

  WUNDERLIST_API_CLIENT_ID = "INSERT WUNDERLIST API CLIENT ID"
  WUNDERLIST_API_TOKEN = "INSERT WUNDERLIST API TOKEN"
  WUNDERLIST_API_HOST = "http://a.wunderlist.com/api/v1/"
  WUNDERLIST_API_PATH_TASKS = "tasks"




  def self.list_tasks_from_list (listId)
    url = "#{WUNDERLIST_API_HOST}#{WUNDERLIST_API_PATH_TASKS}?list_id=#{listId}"
    # params = Hash.new
    # params["list_id"] = listId


    RestClient.proxy = "http://192.168.2.96:8888"
    response = RestClient.get url, {'' 'X-Access-Token' => WUNDERLIST_API_TOKEN, 'X-Client-ID' => WUNDERLIST_API_CLIENT_ID}
    parsed = JSON.parse(response)

    return parsed
  end

end
