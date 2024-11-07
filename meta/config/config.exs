import Config

config :meta, ecto_repos: [Meta.Repo]

config :meta, Meta.Repo,
  username: System.get_env("DB_USER") || "usuario",
  password: System.get_env("DB_PASSWORD") || "secret",
  database: System.get_env("DB_NAME") || "elixir",
  hostname: System.get_env("DB_HOST") || "db",
  port: String.to_integer(System.get_env("DB_PORT") || "3306"),
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")