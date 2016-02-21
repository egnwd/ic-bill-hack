DinnerWith::Application.routes.draw do
  root :to => "home#index"
  get "request/:transaction_id", to: "request#show"
  post "request", to: "request#create"
  get "request/:transaction_id/pay", to: "request#pay"
end
