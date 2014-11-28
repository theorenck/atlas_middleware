class PingController < ApplicationController

  def show
    render json: {alive: true}, status: 200
  end

end
