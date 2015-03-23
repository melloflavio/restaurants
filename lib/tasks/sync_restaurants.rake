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

end
