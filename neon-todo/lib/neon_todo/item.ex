defmodule NeonTodo.Item do
  require Logger
  import Ecto.Query, only: [from: 2]
  use Ecto.Schema

  # weather is the DB table
  schema "items" do
    field :desc, :string
    field :is_done, :boolean
    timestamps()
  end

  @topic "changes"

  def subscribe do
    NeonTodoWeb.Endpoint.subscribe(@topic)
  end

  def broadcast do
    NeonTodoWeb.Endpoint.broadcast(@topic, "changed_items", true)
  end

  def add(desc) do
    res = NeonTodo.Repo.insert!(%NeonTodo.Item{desc: desc})
    broadcast()
    res
  end

  def all() do
    NeonTodo.Repo.all(from i in NeonTodo.Item, order_by: [desc: i.id])
  end

  def toggle(id) do
    from(i in NeonTodo.Item,
      where: i.id == ^id,
      update: [set: [is_done: fragment("not ?", i.is_done)]]
    )
    |> NeonTodo.Repo.update_all([])

    broadcast()
  end

  def delete(id) do
    from(i in NeonTodo.Item, where: i.id == ^id) |> NeonTodo.Repo.delete_all()

    broadcast()
  end

  def delete_completed() do
    {count, _} =
      from(i in NeonTodo.Item, where: i.is_done == true) |> NeonTodo.Repo.delete_all()

    if count > 0 do
      broadcast()
    else
      raise "Nothing to delete"
    end
  end
end
