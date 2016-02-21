class RequestController < ApplicationController
  def create
    render :text => "Create transaction_id: #{params[:transaction_id]}"
  end

  def show
    @request = get_request(params[:mondo_id], params[:transaction_id])
  end

  def pay
    @request = get_request(params[:mondo_id], params[:transaction_id])
  end

  def get_request(mondo_id, transaction_id)
    begin
      request = Request.find(:conditions=>["mondo_id=? and transaction_id=?",
                                            mondo_id, transaction_id])
    rescue
      render :file => "#{Rails.root}/public/404.html",  :status => 404
    end

    return request
  end
end
