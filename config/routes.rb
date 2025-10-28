Rails.application.routes.draw do
  devise_for :customers, controller: {
    sessions: "customers/sessions",
    registrations: "customers/registrations"
  }
  devise_for :admins, controller: {
    sessions: "admins/sessions"
  }

  namespace :admin do
    resources :products, only: %i[ index show create new edit update ]
  end

  root to: "pages#home"
  get "/up/", to: "up#index", as: :up
  get "/up/databases", to: "up#databases", as: :up_databases

  # Sidekiq has a web dashboard which you can enable below. It's turned off by
  # default because you very likely wouldn't want this to be available to
  # everyone in production.
  #
  # Uncomment the 2 lines below to enable the dashboard WITHOUT authentication,
  # but be careful because even anonymous web visitors will be able to see it!
  # require "sidekiq/web"
  # mount Sidekiq::Web => "/sidekiq"
  #
  # If you add Devise to this project and happen to have an admin? attribute
  # on your user you can uncomment the 4 lines below to only allow access to
  # the dashboard if you're an admin. Feel free to adjust things as needed.
  # require "sidekiq/web"
  # authenticate :user, lambda { |u| u.admin? } do
  #   mount Sidekiq::Web => "/sidekiq"
  # end

  # Learn more about this file at: https://guides.rubyonrails.org/routing.html
end
