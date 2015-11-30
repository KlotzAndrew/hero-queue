class SeriesController < ApplicationController
  before_action :set_series, only: [:show]

  def show
  	@series_participations = Series.find(params[:id]).series_participations.includes(:summoner).order(points: :desc)
    @series_points = @series.calculate_stats
  end

  private
    def set_series
      @series = Series.find(params[:id])
    end
end
