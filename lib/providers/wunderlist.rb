module Wunderlist

  require 'rest_client'
  require 'json'

  WUNDERLIST_API_CLIENT_ID = ENV['WUNDERLIST_API_CLIENT_ID']
  WUNDERLIST_API_TOKEN = ENV['WUNDERLIST_API_TOKEN']
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


  def self.list_tasks_from_list (list_id, completed = false)
    url = "#{WUNDERLIST_API_HOST}#{WUNDERLIST_API_PATH_TASKS}?list_id=#{list_id}&completed=#{completed}"
    # params = Hash.new
    # params["list_id"] = listId
    headers = setup_headers


    response = RestClient.get url, headers

    return JSON.parse(response)
  end

  # Wunderlists API only returns either the completed or not completed tasks
  # Requests for both and merges the resulting arrays
  def self.list_all_tasks_from_list(list_id)
    not_completed = self.list_tasks_from_list(list_id, false)
    completed = self.list_tasks_from_list(list_id, true)

    return completed + not_completed
  end

  def self.create_comment_on_task(task_id, comment)
    url = "#{WUNDERLIST_API_HOST}#{WUNDERLIST_API_PATH_TASK_COMMENTS}"
    params = Hash.new
    params["task_id"] = task_id
    params["text"] = comment

    headers = setup_headers
    response = RestClient.post url, params.to_json, headers

    return JSON.parse(response)
  end

  def self.check_comment_existence(task_id, comment_id)
    success = false
    begin
      url = "#{WUNDERLIST_API_HOST}#{WUNDERLIST_API_PATH_TASK_COMMENTS}?task_id=#{task_id}"

      headers = setup_headers
      response = RestClient.get url, headers

      parsed = JSON.parse(response)
      if parsed.respond_to?('each')
        parsed.each do |task|
          if task["id"] == comment_id.to_i
            success = true
            break
          end
        end
      else
        success = true
      end
    rescue => e
      puts "Error when checking for existence of comment = #{comment_id}"
      success = true #An error in accessing the api should not set the restaurant as inactive.
    end

    return success 
  end

  def self.get_task_detail(task_id)
    url = "#{WUNDERLIST_API_HOST}#{WUNDERLIST_API_PATH_TASKS}/#{task_id}"

    headers = setup_headers
    response = RestClient.get url, headers

    return JSON.parse(response)
  end

end
