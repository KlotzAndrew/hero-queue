class StaticPagesController < ApplicationController
  def home
  	@tournament = Tournament.upcoming.first
  end

  def rules
  end

  def format
  end

  def prizing
  end
end
