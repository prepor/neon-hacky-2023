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

  def neon_branch do
    System.get_env("NEON_BRANCH")
  end

  def codespace_for(lsn, sha) do
    {:ok, %{body: branches}} =
      Req.get("https://api.github.com/repos/#{owner()}/#{repo()}/branches",
        auth: {:bearer, token()}
      )

    lsn_for_branch = String.replace(lsn, ~r/[^\w]/, "")

    branch_name = "neon_issue_#{neon_branch()}_#{lsn_for_branch}"
    existing_branch = branches |> Enum.find(fn %{"name" => name} -> branch_name == name end)

    if existing_branch do
      find_codespace(existing_branch)
    else
      create_codespace(branch_name, lsn, sha)
    end
  end

  def find_codespace(existing_branch) do
  end

  def create_codespace(branch_name, lsn, sha) do
    Req.post!("https://api.github.com/repos/#{owner()}/#{repo()}/git/refs",
      auth: {:bearer, token()},
      json: %{
        ref: "refs/heads/#{branch_name}",
        sha: sha
      }
    )

    %{status: 201} =
      Req.put!(
        "https://api.github.com/repos/#{owner()}/#{repo()}/contents/.devcontainer/devcontainer.json",
        auth: {:bearer, token()},
        json: %{
          message: "prepare for codespace",
          commiter: %{name: "neon", email: "neon@neon.tech"},
          branch: branch_name,
          content:
            %{
              containerEnv: %{
                DB_HOST: "#{neon_branch()}.prepor.dev",
                DB_OPTIONS: "neon_lsn:#{lsn} neon_endpoint_type:read_write",
                DB_USER: System.get_env("NEON_USER"),
                DB_PASS: System.get_env("NEON_PASS"),
                DB_PORT: System.get_env("NEON_PORT"),
                NEON_LSN: lsn
              },
              # sudo tailscale up --accept-routes
              runArgs: ["--device=/dev/net/tun"],
              features: %{
                "ghcr.io/tailscale/codespace/tailscale": %{}
              }
            }
            |> Jason.encode!()
            |> Base.encode64()
        }
      )

    %{body: %{"web_url" => web_url}} =
      Req.post!(
        "https://api.github.com/repos/#{owner()}/#{repo()}/codespaces",
        auth: {:bearer, token()},
        json: %{
          ref: branch_name
        }
      )

    web_url
  end
end
