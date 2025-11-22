Blazer::Ai::Engine.routes.draw do
  post "/generate_sql" => "queries#create", as: :generate_sql
end
