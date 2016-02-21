class RequestController < ApplicationController
  def create
    @request = Request.new(params[:request])
    if @request.save
      render :text => "Success: #{@request.inspect}",  :status => 200
    else
      render :text => "Error: Couldn't create transaction.",  :status => 500
    end
  end

  def show
    @request = get_request(params[:mondo_id], params[:transaction_id])
  end

  def pay
    @request = get_request(params[:mondo_id], params[:transaction_id])
  end

  def get_request(mondo_id, transaction_id)
    begin
      requests = Request.where "mondo_id=\'#{mondo_id}\' \
                                AND transaction_id=\'#{transaction_id}\'"
    rescue
      # render :file => "#{Rails.root}/public/404.html",  :status => 404
      render :text => "#{mondo_id} - #{transaction_id}",  :status => 404
    end

    return requests[0]
  end
end
