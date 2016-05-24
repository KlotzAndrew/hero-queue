class StaticPagesController < ApplicationController
  def home
    @tournament = Tournament.upcoming.first || Tournament.last
  end

  def rules
  end

  def format
  end

  def prizing
  end
end
