class TicketsController < ApplicationController
  before_action :set_ticket, only: [:show, :edit, :update, :destroy]
  protect_from_forgery except: [:hook]

  # GET /tickets
  # GET /tickets.json
  def index
    @tickets = Ticket.all
  end

  # GET /tickets/1
  # GET /tickets/1.json
  def show
  end

  # GET /tickets/new
  def new
    @ticket = Ticket.new
  end

  # GET /tickets/1/edit
  def edit
  end

  # POST /tickets
  # POST /tickets.json
  def create
    @ticket = Ticket.new_with_summoner(ticket_params)
    @errors = @ticket.errors.full_messages

    respond_to do |format|
      if @ticket.save
        format.html { redirect_to @ticket, notice: 'Ticket was successfully created.' }
        format.json { render :show, status: :created, location: @ticket }
        format.js
      else
        format.html { render :new }
        format.json { render json: @ticket.errors, status: :unprocessable_entity }
        format.js
      end
    end
  end

  # PATCH/PUT /tickets/1
  # PATCH/PUT /tickets/1.json
  def update
    @ticket = Ticket.new_with_summoner(ticket_params)
    @errors = @ticket.errors.full_messages

    respond_to do |format|
      if @ticket.update(ticket_params)
        format.html { redirect_to @ticket, notice: 'Ticket was successfully updated.' }
        format.json { render :show, status: :ok, location: @ticket }
        format.js
      else
        format.html { render :edit }
        format.json { render json: @ticket.errors, status: :unprocessable_entity }
        format.js
      end
    end
  end

  # DELETE /tickets/1
  # DELETE /tickets/1.json
  def destroy
    @ticket.destroy
    respond_to do |format|
      format.html { redirect_to tickets_url, notice: 'Ticket was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def hook
    params.permit! # Permit all Paypal input params
    Ticket.check_paypal_ipn(params)
    render nothing: true
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_ticket
      @ticket = Ticket.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def ticket_params
      params.require(:ticket).permit(:summonerName, :duoName, :contact_email, :contact_first_name, :contact_last_name, :tournament_id)
    end
end
