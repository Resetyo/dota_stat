Rails.application.routes.draw do
  root 'home#index'
  post 'get_stats', to: 'home#get_stats', as: :get_stats
  get 'result', to: 'home#result', as: :result
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
