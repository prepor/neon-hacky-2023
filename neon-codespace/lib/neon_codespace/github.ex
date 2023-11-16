defmodule NeonCodespace.Github do
  def token do
    System.get_env("GITHUB_TOKEN")
  end

  def repo do
    System.get_env("GITHUB_REPO")
  end

  def owner do
    System.get_env("GITHUB_OWNER")
  end

  def codespace_for(branch, lsn) do
    Req.get("https://api.github.com/repos/#{owner()}/#{repo()}/branches",
      auth: {:bearer, token()}
    )
  end
end
