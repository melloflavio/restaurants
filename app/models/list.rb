# encoding: utf-8
class List
  require 'csv'
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, :type => String
  field :wunderlist_id, :type => String
  field :search_latitude, :type => String
  field :search_longitude, :type => String
  field :search_radius, :type => String
  field :place_types, :type => Array #Types os places to search for. See possible values at https://developers.google.com/places/supported_types
  field :has_new_rests, :type => Boolean, :default => true #Marks if the lists consists of restaurants that I have already been to or not

  has_many :wunderlist_restaurants

  def fetch_restaurants
    restaurants = Wunderlist::list_all_tasks_from_list(self.wunderlist_id)

    restaurants.each do |r|
      new_rest = WunderlistRestaurant.where(:wunderlist_id => r["id"]).first
      if !new_rest
        new_rest = WunderlistRestaurant.new
        new_rest.populate_from_wunderlist_api(r)
        self.wunderlist_restaurants << new_rest
        new_rest.save
      end

    end
  end

  def self.get_csv_header
    header = Array.new
    header << "Nome"
    header << "Lista"
    header << "Telefone"
    header << "Endereço"
    header << "Site"
    header << "Horários"
    header << "Latitude"
    header << "Longitude"

    return header
  end


  def self.write_new_rests_csv
    path = Rails.root.join('export', "new_rests.csv")
    CSV.open(path, 'w') do |csv_object|
      csv_object << self.class.get_csv_header()

      #gets the non completed, valid restaurants from the lists flagged as new
      List.where(:has_new_rests => true).each do |l|
        l.wunderlist_restaurants.where(:completed => false).each do |w|
          w.restaurants.where(:active => true).each do |rest|
            csv_object << rest.get_summary_array()
          end
        end
      end
    end
  end


  def self.write_old_rests_csv
    path = Rails.root.join('export', "old_rests.csv")
    CSV.open(path, 'w') do |csv_object|
      csv_object << self.class.get_csv_header()

      #gets the completed, valid restaurants from the lists flagged as new
      List.where(:has_new_rests => true).each do |l|
        l.wunderlist_restaurants.where(:completed => true).each do |w|
          w.restaurants.where(:active => true).each do |rest|
            csv_object << rest.get_summary_array()
          end
        end
      end

      #gets the valid restaurants from the lists flagged as old
      List.where(:has_new_rests => false).each do |l|
        l.wunderlist_restaurants.all.each do |w|
          w.restaurants.where(:active => true).each do |rest|
            csv_object << rest.get_summary_array()
          end
        end
      end

    end
  end

end
