Rails.application.routes.draw do
  # The Blazer::Ai::Engine will be automatically mounted within the Blazer::Engine via the Railtie
  mount Blazer::Engine => "/insights"
end
