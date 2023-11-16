defmodule NeonTodo.Repo.Migrations.Init do
  use Ecto.Migration

  def change do
    create table("items") do
      add :desc, :string
      add :is_done, :boolean, default: false

      timestamps()
    end
  end
end
