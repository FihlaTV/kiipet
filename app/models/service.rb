class Service < ActiveRecord::Base

  has_many :profile_services
  has_many :profiles, through: :profile_services

  def self.allowed_attributes
    [
      :name, :description
    ]
  end

  def name_with_price
    "#{name} - #{profile_services.first.price}"
  end
end
