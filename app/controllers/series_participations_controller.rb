class SeriesParticipationsController < ApplicationController
  before_action :set_series, only: [:index]

  def index
    @series_participations = @series.series_participations.includes(:summoner).order(points: :desc)
  end

  private
    def set_series
      @series = Series.find(params[:series_id])
    end
end
