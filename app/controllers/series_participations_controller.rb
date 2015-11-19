class SeriesParticipationsController < ApplicationController
  before_action :set_series_participation, only: [:show, :edit, :update, :destroy]

  # GET /series_participations
  # GET /series_participations.json
  def index
    @series_participations = SeriesParticipation.all
  end

  # GET /series_participations/1
  # GET /series_participations/1.json
  def show
  end

  # GET /series_participations/new
  def new
    @series_participation = SeriesParticipation.new
  end

  # GET /series_participations/1/edit
  def edit
  end

  # POST /series_participations
  # POST /series_participations.json
  def create
    @series_participation = SeriesParticipation.new(series_participation_params)

    respond_to do |format|
      if @series_participation.save
        format.html { redirect_to @series_participation, notice: 'Series participation was successfully created.' }
        format.json { render :show, status: :created, location: @series_participation }
      else
        format.html { render :new }
        format.json { render json: @series_participation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /series_participations/1
  # PATCH/PUT /series_participations/1.json
  def update
    respond_to do |format|
      if @series_participation.update(series_participation_params)
        format.html { redirect_to @series_participation, notice: 'Series participation was successfully updated.' }
        format.json { render :show, status: :ok, location: @series_participation }
      else
        format.html { render :edit }
        format.json { render json: @series_participation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /series_participations/1
  # DELETE /series_participations/1.json
  def destroy
    @series_participation.destroy
    respond_to do |format|
      format.html { redirect_to series_participations_url, notice: 'Series participation was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_series_participation
      @series_participation = SeriesParticipation.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def series_participation_params
      params[:series_participation]
    end
end
