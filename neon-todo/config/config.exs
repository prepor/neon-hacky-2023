# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :neon_todo,
  ecto_repos: [NeonTodo.Repo],
  generators: [timestamp_type: :utc_datetime]

config :sentry,
  dsn:
    "https://0d86478dbae1dff3a23a23c294bbcc67@o4506236125970432.ingest.sentry.io/4506236127084544",
  enable_source_code_context: true,
  root_source_code_paths: [File.cwd!()],
  environment_name: Mix.env(),
  included_environments: [:prod, :dev]

# Configures the endpoint
config :neon_todo, NeonTodoWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Phoenix.Endpoint.Cowboy2Adapter,
  render_errors: [
    formats: [html: NeonTodoWeb.ErrorHTML, json: NeonTodoWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: NeonTodo.PubSub,
  live_view: [signing_salt: "1/sguvrv"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :neon_todo, NeonTodo.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.3.2",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
