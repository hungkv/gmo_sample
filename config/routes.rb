Rails.application.routes.draw do
  get 'payments/unionpay_start'

	root to: 'store#index'
  resources :charges
  get "payments/confirm" => "payments#confirm"
  post "payments/create_payment" => "payments#create_payment"
	# For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
