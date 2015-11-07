class Calendar < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true

  belongs_to :profile, inverse_of: :calendar
  belongs_to :booking
end
