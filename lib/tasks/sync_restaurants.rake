namespace :wunderlist_restaurants do

  desc "Fetch restaurants from wunderlist fetches their data from google and saves back to wunderlist"
  task :update_restaurants => :environment do
    puts "Begin update"
    lists = List.all
    lists.each do |l|
      l.fetch_restaurants
    end
  end

end
