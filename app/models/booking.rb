require_relative './concerns/bookable'

class Booking < ActiveRecord::Base
  include Bookable
  attr_accessor :title

  after_initialize :set_initial_status

  scope :get_calendar, -> (calendar_id, availability=nil) do
    if availability == "available"
      get_booking_with_calendar(calendar_id).status(:available).where("end_time >= ?", Time.now)
    elsif availability == "taken"
      get_booking_with_calendar(calendar_id).status(:taken)
    else
      get_booking_with_calendar(calendar_id)
    end
  end

  scope :get_valid_bookings, -> { where("end_time >= ?", Time.now).order(:start_time) }
  scope :get_booking_with_calendar, ->(calendar_id) { where("calendar_id = ?", calendar_id).order(:start_time) }
  scope :status, ->(status){ where(state: status ) }


  belongs_to :profile
  belongs_to :profile_service

  state_machine :state, :initial => :available do
    state :available, :taken

    event :take do
      transition available: :taken
    end

    event :available do
      transition taken: :available
    end
  end

  def title
    if self.state == "taken"
      "Ocupado"
    elsif self.state == "available"
      "Disponible"
    end
  end

  def service_name
    profile_service.service.name
  end

  def set_initial_status
    self.state ||= :available
  end

  def payment!(return_url, cancel_url, notify_url)
   amount = 1
   client = Khipu::PaymentsApi.new
   profile_service = self.profile_service
   amount = profile_service.price.to_i if profile_service.price.to_i > 0
   response = client.payments_post("Kiipet - Pagar resevar", 'CLP', amount, {
      transaction_id: self.id,
      expires_date: DateTime.new(2016, 4, 4),
      body: 'Estas pagando el precio del servicio que solicitaste para tu mascota',
      picture_url: 'http://kiipet.com/assets/logokhipupayment-ffefb9825d678627a873db3c4299143d860333a0a8fd6d4fe711de4d23b24f8f.png',
      return_url: return_url,
      cancel_url: cancel_url,
      notify_url: notify_url,
      notify_api_version: '1.3'
   })

   self.payment_id = response.payment_id if response
   self.save
   p = Payment.create(payment_id: response.payment_id, booking_id: self.id, profile_id: self.profile_id, amount: amount)
   p.save

    return response
  end
end
