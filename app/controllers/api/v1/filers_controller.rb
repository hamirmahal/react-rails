class Api::V1::FilersController < ApplicationController
  def index
    @filers = Filer.all
    @filers = @filers.paginate(page: params[:page], per_page: 100)
    render json: @filers
  end
end
