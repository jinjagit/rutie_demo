Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :app_configs
  get '/', to: 'hello#hello'
  get 'arrays/reverse', to: 'arrays#reverse'
  get 'arrays/blocked_words', to: 'arrays#blocked_words'
  get 'vericred_example', to: 'vericred#example'
end
