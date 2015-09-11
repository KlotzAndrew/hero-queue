class StaticPagesController < ApplicationController
  def home
  	@tournament = Tournament.last
  end

  def about
  end

  def faq
  end

  def rules
  end

  def format
  end
end
