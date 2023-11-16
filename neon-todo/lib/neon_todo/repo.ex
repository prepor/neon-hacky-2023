defmodule NeonTodo.Repo do
  use Ecto.Repo,
    otp_app: :neon_todo,
    adapter: Ecto.Adapters.Postgres
end
