class Api::V1::RecipientsController < ApplicationController
  def index
    if params[:form_id]
      @recipients = Recipient.where(form_id: params[:form_id])
    elsif params[:state]
      @recipients = Recipient.where(state: params[:state])
    else
      @recipients = Recipient.all
    end
    @recipients = @recipients.paginate(page: params[:page], per_page: 100)
    render json: @recipients
  end

  def cash_grants
    # If only the form_id is specified, show
    # awards by the passed filer.
    if !params[:amount] && !params[:condition]
      form_id = params[:form_id]
      puts "form_id"
      puts form_id
      recipients =
        Recipient
          .where(form_id: form_id)
          .paginate(page: params[:page], per_page: 100)
          .pluck(:cash_grant)
      render json: recipients
      return
    end

    # Otherwise, filter recipients by cash amount.
    condition = params[:condition] || "="
    amount = params[:amount].to_i || 0

    case condition
    when "<"
      recipients = Recipient.where("cash_grant < ?", amount)
    when "<="
      recipients = Recipient.where("cash_grant <= ?", amount)
    when "="
      recipients = Recipient.where("cash_grant = ?", amount)
    when ">="
      recipients = Recipient.where("cash_grant >= ?", amount)
    when ">"
      recipients = Recipient.where("cash_grant > ?", amount)
    else
      recipients = Recipient.where(form_id: form_id)
    end

    recipients = recipients.paginate(page: params[:page], per_page: 100)
    render json: recipients
  end
end
