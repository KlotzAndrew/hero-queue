class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
	include SessionsHelper

  before_action :set_series

	private
    def logged_in_user
      unless logged_in?
        store_location
        flash[:danger] = "Please log in."
        redirect_to login_url
      end
    end  

    def set_series
      @series = Series.newest.first
    end
end
