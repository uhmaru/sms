require "sidekiq/web"

Rails.application.routes.draw do
  authenticate :user, lambda { |u| u.admin? } do
    mount Sidekiq::Web => "/sidekiq"
  end

  get "up" => "rails/health#show", as: :rails_health_check

  devise_for :users,
             path: "api/v1",
             path_names: {
               sign_in: "login",
               sign_out: "logout"
             },
             controllers: {
               sessions: "api/v1/sessions",
               registrations: "api/v1/registrations"
             },
             defaults: { format: :json }

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :messages, only: [:create, :index] do
        patch :update_status, on: :member
      end

      post "/twilio/status_callback", to: "twilio_webhooks#create"
    end
  end
end
