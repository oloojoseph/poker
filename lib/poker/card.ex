defmodule Poker.Card do
  alias Poker.Breakdown
  alias Poker.Rankings

  def list_clubs(), do: ["C", "D", "H", "S"]
  def list_ranks(), do: ["2", "3", "4", "5", "6", "7", "8", "9", "T", "J", "Q", "K", "A"]

  def clubs(), do: :clubs

  def diamonds(), do: :diamonds

  def hearts(), do: :hearts

  def spades(), do: :spades

  def ace(), do: :ace

  def king(), do: :king

  def queen(), do: :queen

  def jack(), do: :jack

  def ten(), do: :ten

  def clubs(rank), do: %{suit: :clubs, rank: rank}

  def diamonds(rank), do: %{suit: :diamonds, rank: rank}

  def hearts(rank), do: %{suit: :hearts, rank: rank}

  def spades(rank), do: %{suit: :spades, rank: rank}

  def ranking!(card, other_card) do
    to_integer(card.rank) > to_integer(other_card.rank)
  end

  def consecutive_rank?(%{rank: rank}, %{rank: other_rank}) do
    to_integer(rank) + 1 == to_integer(other_rank)
  end

  def same_suit?(%{suit: suit}, %{suit: other_suit}) do
    suit == other_suit
  end

  defp to_integer(params) do
    case params do
      :ten -> 10
      :jack -> 11
      :queen -> 12
      :king -> 13
      :ace -> 14
      params when is_integer(params) -> params
      _ -> params
    end
  end

  def highest_card(cards) do
    cards
    |> Enum.reduce(fn x, acc ->
      case ranking!(x, acc) do
        true -> x
        false -> acc
      end
    end)

    # [max | rest] = cards
    # value = Enum.reduce(rest, max, fn x , v ->
    #   case  v < x do
    #     true -> x
    #     false -> v
    #   end
    #  end)
    #
  end

  def sort_by_rank(cards) do
    cards
    |> Enum.sort(&ranking!/2)
    |> Enum.reverse()
  end

  def play(p1, v1, p2, v2) do
    split =
      v1
      |> String.trim()
      |> Breakdown.get_hand()

    split_2 =
      v2
      |> String.trim()
      |> Breakdown.get_hand()

    first_player = %{name: p1, hand: split}
    second_player = %{name: p2, hand: split_2}

    winner =
      case Rankings.play_against(first_player.hand, second_player.hand) do
        %{first: "first", hand: hand} -> %{name: first_player.name, hand: hand}
        %{second: "second", hand: hand} -> %{name: second_player.name, hand: hand}
        :tie -> :tie
      end

    winner
    |> print()
  end

  def print(:tie) do
    "tie"
  end

  def print(%{name: name, hand: hand}) do
    if hand.name == :high_card do
      value =
        hand.name
        |> Atom.to_string()
        |> String.replace("_", " ")

      rank = (hand.point |> Enum.at(0)).rank
      suit = (hand.point |> Enum.at(0)).suit |> Atom.to_string()

      ~s"Winner is #{name}. (#{value} of #{rank} #{suit})"
    else
      value =
        hand.name
        |> Atom.to_string()
        |> String.replace("_", " ")

      ~s"Winner is #{name}. (#{value})"
    end

    # for res <- Rankings.query(hand).point do
    # ~s"""
    # #{res.rank} #{res.suit}
    # """
    # end
  end
end
