class List
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, :type => String
  field :wunderlist_id, :type => String

  has_many :wunderlist_restaurants
end
