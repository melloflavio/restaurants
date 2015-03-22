module Wunderlist

  require 'rest_client'
  require 'json'

  WUNDERLIST_API_CLIENT_ID = "INSERT WUNDERLIST API CLIENT ID"
  WUNDERLIST_API_TOKEN = "INSERT WUNDERLIST API TOKEN"
  WUNDERLIST_API_HOST = "http://a.wunderlist.com/api/v1/"
  WUNDERLIST_API_PATH_TASKS = "tasks"
  WUNDERLIST_API_PATH_TASK_COMMENTS = "task_comments"

  def self.setup_headers
    headers = Hash.new
    headers["X-Client-ID"] = WUNDERLIST_API_CLIENT_ID
    headers["X-Access-Token"] = WUNDERLIST_API_TOKEN
    headers["Content-Type"] = "application/json"

    return headers
  end


  def self.list_tasks_from_list (listId)
    url = "#{WUNDERLIST_API_HOST}#{WUNDERLIST_API_PATH_TASKS}?list_id=#{listId}"
    # params = Hash.new
    # params["list_id"] = listId
    headers = setup_headers


    response = RestClient.get url, headers

    return JSON.parse(response)
  end

  def self.create_comment_on_task(taskId, comment)
    url = "#{WUNDERLIST_API_HOST}#{WUNDERLIST_API_PATH_TASK_COMMENTS}"
    params = Hash.new
    params["task_id"] = taskId
    params["text"] = comment

    headers = setup_headers

    response = RestClient.post url, params.to_json, headers

    return JSON.parse(response)
  end

end
