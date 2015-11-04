class StaticPagesController < ApplicationController
  def home
  	@tournament = Tournament.find(1)
  end

  def rules
  end

  def format
  end

  def prizing
  end
end
