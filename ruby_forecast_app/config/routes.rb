Rails.application.routes.draw do
  get 'results/index'

  get 'account/', to: 'account#index'
  get 'sessions/', to: 'session#index'
  get 'sessions/:session_id', controller: 'session', action: 'session_status'
  post 'account/upload'
  get 'results/:session_id', to: 'results#index'
  get 'results/champion/:dataset_name/:target_column', controller: 'results', action: 'champion'
  get 'results/file/:session_id', to: 'results#file'
  get 'results/model/:model_id', to: 'results#model'
  get 'results/contest/:session_id', to: 'results#contest'
  get 'results/anomaly/:session_id', to: 'results#anomaly'
  get 'results/featureimportance/:session_id', to: 'results#features'
  get 'sessions/forecast/:dataset_name', controller: 'session', action: 'forecast', :constraints => { :dataset_name => /[^\/]+/ }
  get 'sessions/impact/:dataset_name', controller: 'session', action: 'impact', :constraints => { :dataset_name => /[^\/]+/ }
  post 'sessions/forecast/:dataset_name', controller: 'session', action: 'create_forecast', :constraints => { :dataset_name => /[^\/]+/ }
  post 'sessions/impact/:dataset_name', controller: 'session', action: 'create_impact', :constraints => { :dataset_name => /[^\/]+/ }
  get 'sessions/delete/:session_id', controller: 'session', action: 'delete'
  get 'sessions/model/:dataset_name', controller: 'session', action: 'model', :constraints => { :dataset_name => /[^\/]+/ }
  post 'sessions/model', controller: 'session', action: 'create_model'
  get 'dataset/delete/:dataset_name', controller: 'dataset', action: 'delete', :constraints => { :dataset_name => /[^\/]+/ }
  get 'dataset/', to: 'dataset#index'
  get 'dataset/detail/:dataset_name', to: 'dataset#detail', :constraints => { :dataset_name => /[^\/]+/ }
  post 'dataset/update', controller: 'dataset', action: 'update'
  get 'views/', to: 'view#index'
  get 'views/detail/:view_name', to: 'view#detail', :constraints => { :view_name => /[^\/]+/ }
  post 'views/update', controller: 'view', action: 'update'
  get 'views/delete/:view_name', controller: 'view', action: 'delete', :constraints => { :view_name => /[^\/]+/ }
  get 'views/create', to: 'view#create'
  post 'views/create_view', to: 'view#create_view'
  get 'models/', to: 'model#index'
  get 'models/:model_id', to: 'model#model'
  get 'models/delete/:model_id', to: 'model#delete'
  get 'models/predict/:model_id', to: 'model#predict'
  post 'models/upload', to: 'model#upload'
  post 'models/prediction', to: 'model#prediction'
  get 'imports/', to: 'import#index'
  get 'imports/:import_id', to: 'import#detail'
  post 'account/set_session_key', to: 'account#set_session_key'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
