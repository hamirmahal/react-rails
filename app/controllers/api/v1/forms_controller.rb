class Api::V1::FormsController < ApplicationController
  def index
    if params[:filer_ein]
      @forms = Form.where(filer_ein: params[:filer_ein])
    else
      @forms = Form.all
    end
    @forms = @forms.paginate(page: params[:page], per_page: 100)
    render json: @forms
  end
end
