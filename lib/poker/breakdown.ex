defmodule Poker.Breakdown do
  alias Poker.Card

  def struct_map(cards) do
    %{cards: cards}
  end

  def get_hand(params) do
    cards =
      params
      |> String.split(" ")
      |> Enum.map(fn x -> get_card(x) end)

    struct_map(cards)
  end

  defp get_card(params) do
    rank =
      params
      |> String.at(0)
      |> get_rank()

    suit =
      params
      |> String.at(1)
      |> get_suit()

    %{suit: suit, rank: rank}
  end

  defp get_suit(params) do
    case params do
      "C" -> Card.clubs()
      "D" -> Card.diamonds()
      "H" -> Card.hearts()
      _ -> Card.spades()
    end
  end

  defp get_rank(params) do
    case params do
      "A" -> Card.ace()
      "K" -> Card.king()
      "Q" -> Card.queen()
      "J" -> Card.jack()
      "T" -> Card.ten()
      _ -> String.to_integer(params)
    end
  end
end
