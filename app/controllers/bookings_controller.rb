class BookingsController < ApplicationController
  before_action :authenticate_user!
  respond_to :html, :xml, :json, :js

  before_action :find_calendar

  def index
    @bookings = Booking.get_calendar(@calendar.id, params[:state] )
    respond_with @bookings
  end

  def new
    @profiles = @calendar.profile
    @booking = Booking.new(calendar_id: @calendar.id)
  end

  def create
    @booking =  Booking.new(params[:booking].permit(:calendar_id, :start_time, :end_time))
    @booking.profile_id = current_user.id
    @booking.profile_service_id = params[:service][:profile_service_id]
    @booking.calendar = @calendar

    respond_to do |format|
      if @booking.save
        flash[:success] = "Se ha creado exitosamente"
        format.js { render action: "create" }
        format.json { head :no_content }
        #payment_url = @booking.payment!
        #redirect_to payment_url.payment_url
      else
        render 'new'
      end
    end
  end

  def show
    @booking = Booking.find(params[:id])
=begin para mostrar el servicio que fue reservado
sin tener que hacer tantas consultas en la vista.
=end
    @profile_service = @booking.profile_service
    @service = @profile_service.service
  end

  def destroy
   @booking = Booking.find(params[:id])
   @booking.destroy

   respond_to do |format|
      format.html { redirect_to ponies_url }
      format.json { head :no_content }
      format.js   { render :layout => false }
   end
  end

  def edit
    @booking = Booking.find(params[:id])
  end

  def update
    @booking = Booking.find(params[:id])
    # @booking.calendar = @calendar

    if @booking.update(params[:booking].permit(:calendar_id, :start_time, :end_time))
      flash[:notice] = 'Your booking was updated succesfully'

      if request.xhr?
        render json: {status: :success}.to_json
      else
        redirect_to calendar_bookings_path(@calendar)
      end
    else
      render 'edit'
    end
  end

  private

  def save booking
    if @booking.save
        flash[:notice] = 'booking added'
        redirect_to calendar_booking_path(@calendar, @booking)
      else
        render 'new'
      end
  end

  def find_calendar
    if params[:calendar_id]
      @calendar = Calendar.find_by_id(params[:calendar_id])
    end
  end

end
