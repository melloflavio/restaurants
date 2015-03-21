class Restaurant
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name
  field :address
end
