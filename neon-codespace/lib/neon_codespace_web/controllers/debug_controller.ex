defmodule NeonCodespaceWeb.DebugController do
  use NeonCodespaceWeb, :controller

  def index(conn, params) do
    codespace_url = NeonCodespace.Github.codespace_for(params["lsn"], params["sha"])
    redirect(conn, to: codespace_url)
  end
end
