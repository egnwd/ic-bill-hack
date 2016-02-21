DinnerWith::Application.routes.draw do
  get "request/create"

  get "request/show"

  get "request/pay"

  root :to => "home#index"
  get "request/:mondo_id/:transaction_id", to: "request#show"
  post "request", to: "request#create"
  get "request/:mondo_id/:transaction_id/pay", to: "request#pay"
end
