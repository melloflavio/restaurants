namespace :wunderlist_restaurants do

  desc "Fetch restaurants from wunderlist fetches their data from google and saves back to wunderlist"
  task :update_restaurants_from_wunderlist => :environment do
    puts "Begin update from wunderlist"
    lists = List.all
    lists.each do |l|
      l.fetch_restaurants
    end
    puts "Finished update from wunderlist"
  end

  task :update_restaurants_details_from_google => :environment do
    puts "Begin update from google"
    wunder_restaurants = WunderlistRestaurant.all
    wunder_restaurants.each do |w|
      w.fetch_restaurants_details_from_google
    end
    puts "Finished update from google"
  end

  task :send_restaurants_details_to_wunderlist => :environment do
    puts "Sending comments back to wunderlist"
    restaurants = Restaurant.where(:sent_to_wunderlist => false)
    restaurants.each do |r|
      r.send_comment_to_wunderlist
    end
    puts "Finished comments back to wunderlist"
  end

  task :pool_wunderlist_for_active => :environment do
    puts "Pooling wunderlist to check Restaurant Status"
    restaurants = Restaurant.where(:active => true, :sent_to_wunderlist => true)
    restaurants.each do |r|
      r.pool_wunderlist_status
    end
    puts "Finished updating restaurant status"
  end

  task :pool_wunderlist_for_name => :environment do
    puts "Begin update for wunderlist name"
    wunder_restaurants = WunderlistRestaurant.all
    wunder_restaurants.each do |w|
      begin
        w.pool_wunderlist_for_name_change
      rescue
        puts "Error pooling wunder_rest id = #{w.wunderlist_id}"
      end
    end
    puts "Finished update for wunderlist name"
  end

  task :pool_wunderlist_for_completion => :environment do
    puts "Begin update for completion"
    wunder_restaurants = WunderlistRestaurant.all
    wunder_restaurants.each do |w|
      begin
        w.pool_wunderlist_for_completion
      rescue
        puts "Error pooling wunder_rest id = #{w.wunderlist_id}"
      end
    end
    puts "Finished update for completion"
  end

  task :generate_csv => :environment do
    puts "Begin csv generation"
    Restaurant.write_rests_csv()
    puts "Finished csv generation"
  end

end
