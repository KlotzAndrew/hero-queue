class StaticPagesController < ApplicationController
  def home
  	@tournament = Tournament.last
  end

  def rules
  end

  def format
  end
end
