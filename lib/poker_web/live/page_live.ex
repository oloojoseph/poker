defmodule PokerWeb.PageLive do
  use PokerWeb, :live_view
  alias Poker.Card

  @impl true
  def mount(_params, _session, socket) do
    user_one = MnemonicSlugs.generate_slug(2)
    user_two = MnemonicSlugs.generate_slug(2)

    # {:ok, assign(socket, result: "", data_one: "2H 3D 5S 9C KD", data_two: "2C 3H 4S 8C KH", user_one: user_one, user_two: user_two, loading: false)}

    {:ok,
     assign(socket,
       result: "",
       data_one: random_one(),
       data_two: random_two(),
       user_one: user_one,
       user_two: user_two,
       loading: false
     )}
  end

  @impl true
  def handle_event("play", params, socket) do
    send(
      self(),
      {:run_play, params["player_one"], params["value_one"], params["player_two"],
       params["value_two"]}
    )

    {:noreply, assign(socket, result: [], loading: true)}
  end

  @impl true
  def handle_info({:run_play, p1, v1, p2, v2}, socket) do
    result = Card.play(p1, v1, p2, v2)
    {:noreply, assign(socket, result: result, loading: false, data_one: v1, data_two: v2)}
  end

  @impl true
  def handle_event("random", _, socket) do
    {:noreply, assign(socket, data_one: random_one(), data_two: random_two(), result: [])}
  end

  def random_one() do
    Enum.map(
      0..4,
      fn _x ->
        Enum.into([Card.list_ranks() |> Enum.random(), Card.list_clubs() |> Enum.random()], " ")
      end
    )
  end

  def random_two() do
    Enum.map(
      0..4,
      fn _x ->
        Enum.into([Card.list_ranks() |> Enum.random(), Card.list_clubs() |> Enum.random()], " ")
      end
    )
  end
end
