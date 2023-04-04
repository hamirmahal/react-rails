class Api::V1::FilersController < ApplicationController
  def index
    if params[:ein]
      @filers = Filer.where(ein: params[:ein])
    else
      @filers = Filer.all
    end
    @filers = @filers.paginate(page: params[:page], per_page: 100)
    render json: @filers
  end
end
