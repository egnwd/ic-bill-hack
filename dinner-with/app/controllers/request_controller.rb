class RequestController < ApplicationController
  def create
    render :text => "Create transaction_id: #{params[:transaction_id]}"
  end

  def show
    @transaction_id = params[:transaction_id]
  end

  def pay
    @transaction_id = params[:transaction_id]
  end
end
