defmodule NeonTodoWeb.ListLive do
  use Phoenix.LiveView

  def mount(_, _, socket) do
    NeonTodo.Item.subscribe()
    items = NeonTodo.Item.all()
    {:ok, socket |> assign(:items, items)}
  end

  def render(assigns) do
    ~H"""
    <.live_component module={NeonTodoWeb.ListComponent} id="root" items={@items} />
    """
  end

  def handle_info(%{topic: "changes", event: "changed_items"}, socket) do
    items = NeonTodo.Item.all()
    {:noreply, socket |> assign(:items, items)}
  end
end

defmodule NeonTodoWeb.ListComponent do
  use Phoenix.LiveComponent

  def mount(socket) do
    {:ok,
     socket
     |> assign(
       :new_item,
       %NeonTodo.Item{}
       |> Ecto.Changeset.change()
       |> to_form()
     )}
  end

  def render(assigns) do
    ~H"""
    <section class="todoapp">
      <header class="header">
        <h1>todos</h1>
        <.form for={@new_item} phx-submit="add_item" phx-target={@myself}>
          <.new_item field={@new_item[:desc]} />
        </.form>
      </header>

      <section class="main">
        <ul class="todo-list">
          <%= for item <- @items do %>
            <.item item={item} myself={@myself} />
          <% end %>
        </ul>
      </section>

      <footer class="footer">
        <button class="clear-completed" phx-click="delete-completed" phx-target={@myself}>
          Clear completed
        </button>
      </footer>
    </section>
    """
  end

  def new_item(assigns) do
    ~H"""
    <input
      type="text"
      name={@field.name}
      id={@field.id}
      value={@field.value}
      class="new-todo"
      placeholder="What needs to be done?"
    />
    """
  end

  def item(assigns) do
    ~H"""
    <li>
      <div class="view">
        <input
          class="toggle"
          type="checkbox"
          checked={@item.is_done}
          phx-click="toggle"
          phx-target={@myself}
          phx-value-id={@item.id}
        />
        <label>
          <%= @item.desc %>
        </label>
        <button class="destroy" phx-click="delete" phx-target={@myself} phx-value-id={@item.id} />
      </div>
    </li>
    """
  end

  def input(assigns) do
    ~H"""
    <input type="text" name={@field.name} id={@field.id} value={@field.value} />
    """
  end

  def handle_event("add_item", %{"item" => item_params}, socket) do
    item = NeonTodo.Item.add(item_params["desc"])
    {:noreply, socket |> update(:items, fn items -> [item | items] end)}
  end

  def handle_event("toggle", %{"id" => id}, socket) do
    NeonTodo.Item.toggle(id)

    {:noreply, socket}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    NeonTodo.Item.delete(id)

    {:noreply, socket}
  end

  def handle_event("delete-completed", _, socket) do
    NeonTodo.Item.delete_completed()

    {:noreply, socket}
  end
end
