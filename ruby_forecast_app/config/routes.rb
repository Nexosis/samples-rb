Rails.application.routes.draw do
  get 'results/index'

  get 'account/', to: 'account#index'
  get 'account/sessions'
  get 'account/session/:session_id', controller: 'account', action: 'session_status'
  post 'account/upload'
  get 'results/:sessionId', to: 'results#index'
  get 'results/champion/:dataset_name/:target_column', controller: 'results', action: 'champion'
  get 'results/file/:sessionId', to: 'results#file'
  get 'account/forecast/:dataset_name', controller: 'account', action: 'forecast', :constraints => { :dataset_name => /[^\/]+/ }
  get 'account/impact/:dataset_name', controller: 'account', action: 'impact', :constraints => { :dataset_name => /[^\/]+/ }
  post 'account/forecast/:dataset_name', controller: 'account', action: 'create_forecast', :constraints => { :dataset_name => /[^\/]+/ }
  post 'account/impact/:dataset_name', controller: 'account', action: 'create_impact', :constraints => { :dataset_name => /[^\/]+/ }
  get 'account/delete/:dataset_name', controller: 'account', action: 'delete_dataset', :constraints => { :dataset_name => /[^\/]+/ }
  get 'dataset/', to: 'dataset#index'
  get 'dataset/detail/:dataset_name', to: 'dataset#detail', :constraints => { :dataset_name => /[^\/]+/ }
  post 'dataset/update', controller: 'dataset', action: 'update'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
