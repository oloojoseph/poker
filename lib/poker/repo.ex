defmodule Poker.Repo do
  use Ecto.Repo,
    otp_app: :poker,
    adapter: Ecto.Adapters.MyXQL
end
