class SeriesParticipationsController < ApplicationController

  def index
    @series_participations = Series.find(params[:series_id]).series_participations.includes(:summoner)
  end

  private
end
