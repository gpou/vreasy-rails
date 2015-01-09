Rails.application.routes.draw do

  resources :task_logs

  resources :tasks do
    member do
      get :sms
      get :empty_log
    end
  end

  post 'twilio/sms' => 'twilio#sms'
  post 'twilio/status' => 'twilio#status'

  root :to => "tasks#index"

end
