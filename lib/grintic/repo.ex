defmodule Grintic.Repo do
  use Ecto.Repo,
    otp_app: :grintic,
    adapter: Ecto.Adapters.Postgres
end
