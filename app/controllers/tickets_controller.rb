class TicketsController < ApplicationController
  before_action :set_ticket, only: [:show, :edit, :update, :destroy]

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
    summoner = Summoner.new(summonerName: params[:ticket][:summonerName])
    @ticket = Ticket.new(ticket_params)
    @summoner = summoner.find_or_create
    if params[:ticket][:duoName].length > 1
      duo = Summoner.new(summonerName: params[:ticket][:duoName])
      @duo = duo.find_or_create
      @ticket.update(duo_id: @duo.id)
    end
    @ticket.update(summoner_id: @summoner.id)

    respond_to do |format|
      if @ticket.save
        format.html { redirect_to @ticket, notice: 'Ticket was successfully created.' }
        format.json { render :show, status: :created, location: @ticket }
        format.js { @ticket }
      else
        format.html { render :new }
        format.json { render json: @ticket.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tickets/1
  # PATCH/PUT /tickets/1.json
  def update
    @ticket = Ticket.new(ticket_params)
    summoner = Summoner.new(summonerName: params[:ticket][:summonerName])
    @summoner = summoner.find_or_create
    @ticket.update(summoner_id: @summoner.id)
    if params[:ticket][:duoName].length > 1
      duo = Summoner.new(summonerName: params[:ticket][:duoName])
      @duo = duo.find_or_create
      @ticket.update(duo_id: @duo.id)
    end

    respond_to do |format|
      if @ticket.update(ticket_params)
        format.html { redirect_to @ticket, notice: 'Ticket was successfully updated.' }
        format.json { render :show, status: :ok, location: @ticket }
        format.js { @ticket }
      else
        format.html { render :edit }
        format.json { render json: @ticket.errors, status: :unprocessable_entity }
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
