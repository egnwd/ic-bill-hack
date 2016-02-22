class Request < ActiveRecord::Base
  attr_accessible :amount, :mondo_id, :transaction_id, :who_from
end
