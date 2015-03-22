class WunderlistRestaurant
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, :type => String
  field :wunderlist_id, :type => String
  field :list_id, :type => String

  belongs_to :list
  has_many :restaurants

  def populate_from_wunderlist_api(detail)
    self.name = detail["title"]
    self.wunderlist_id = detail["id"]
    self.list_id = detail["list_id"]
  end

end
