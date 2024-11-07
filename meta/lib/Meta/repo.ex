defmodule Meta.Repo do
  use Ecto.Repo,
    otp_app: :meta,
    adapter: Ecto.Adapters.MyXQL
end
