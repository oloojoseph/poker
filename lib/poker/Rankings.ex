defmodule Poker.Rankings do
  alias Poker.Card

  def play_against(hand, other_hand) do
    if query(hand).name == :high_card && query(other_hand).name == :high_card do
      ######## remove matching rank level one
      if (query(hand).point |> Enum.at(0)).rank == (query(other_hand).point |> Enum.at(0)).rank do
        hand_1 = %{cards: hand.cards -- query(hand).point}
        otherhand_1 = %{cards: other_hand.cards -- query(other_hand).point}

        ######## remove matching rank level two
        if (query(hand_1).point |> Enum.at(0)).rank ==
             (query(otherhand_1).point |> Enum.at(0)).rank do
          hand_2 = %{cards: hand_1.cards -- query(hand_1).point}
          otherhand_2 = %{cards: otherhand_1.cards -- query(otherhand_1).point}

          ######## remove matching rank level three
          if (query(hand_2).point |> Enum.at(0)).rank ==
               (query(otherhand_2).point |> Enum.at(0)).rank do
            hand_3 = %{cards: hand_2.cards -- query(hand_2).point}
            otherhand_3 = %{cards: otherhand_2.cards -- query(otherhand_2).point}

            case compare(
                   query(hand_3) |> Map.replace(:name, "high_card"),
                   query(otherhand_3) |> Map.replace(:name, "high_card")
                 ) do
              {:first, _} -> %{first: "first", hand: query(hand_3)}
              {:second, _} -> %{second: "second", hand: query(otherhand_3)}
              :tie -> :tie
            end
          else
            case compare(
                   query(hand_2) |> Map.replace(:name, "high_card"),
                   query(otherhand_2) |> Map.replace(:name, "high_card")
                 ) do
              {:first, _} -> %{first: "first", hand: query(hand_2)}
              {:second, _} -> %{second: "second", hand: query(otherhand_2)}
              :tie -> :tie
            end
          end
        else
          case compare(
                 query(hand_1) |> Map.replace(:name, "high_card"),
                 query(otherhand_1) |> Map.replace(:name, "high_card")
               ) do
            {:first, _} -> %{first: "first", hand: query(hand_1)}
            {:second, _} -> %{second: "second", hand: query(otherhand_1)}
            :tie -> :tie
          end
        end
      else
        case compare(
               query(hand) |> Map.replace(:name, "high_card"),
               query(other_hand) |> Map.replace(:name, "high_card")
             ) do
          {:first, _} -> %{first: "first", hand: query(hand)}
          {:second, _} -> %{second: "second", hand: query(other_hand)}
          :tie -> :tie
        end
      end
    else
      case compare(query(hand), query(other_hand)) do
        {:first, _} -> %{first: "first", hand: query(hand)}
        {:second, _} -> %{second: "second", hand: query(other_hand)}
        :tie -> :tie
      end
    end
  end

  def compare(rank, other_rank) do
    cond do
      ranking!(rank, other_rank) ->
        {:first, rank}

      ranking!(other_rank, rank) ->
        {:second, other_rank}

      is_nil(rank) || is_nil(other_rank) ->
        :tie

      true ->
        compare_by_highest_card(rank, other_rank)
    end
  end

  defp ranking!(rank, other_rank) do
    to_integer(rank) > to_integer(other_rank)
  end

  defp to_integer(params) do
    case params.name do
      :straight_flush -> 9
      :four_of_kind -> 8
      :fullhouse -> 7
      :flush -> 6
      :straight -> 5
      :three_of_kind -> 4
      :two_pair -> 3
      :one_pair -> 2
      _ -> 1
    end
  end

  defp compare_by_highest_card(rank, other_rank) do
    card = Card.highest_card(rank.point)
    other_card = Card.highest_card(other_rank.point)

    cond do
      Card.ranking!(card, other_card) ->
        {:first, rank}

      Card.ranking!(other_card, card) ->
        {:second, other_rank}

      true ->
        :tie
    end
  end

  defp straight_flush_from(cards) do
    straight = straight_from(cards)
    flush = flush_from(cards)

    point =
      case straight.point == Card.sort_by_rank(flush.point) do
        true ->
          straight.point

        false ->
          []
      end

    hand_struct(point, :straight_flush)
  end

  defp four_of_kind_from(cards) do
    cards
    |> group_cards_by_same_rank()
    |> with_a_number_of_cards(4)
    |> hand_struct(:four_of_kind)
  end

  defp fullhouse_from(cards) do
    three_of_kind = three_of_kind_from(cards)
    one_pair = one_pair_from(cards)

    # case IO.inspect( has_point?(three_of_kind) && has_point?(one_pair)) do
    point =
      case three_of_kind.point != [] && one_pair.point != [] do
        true ->
          three_of_kind.point ++ one_pair.point

        false ->
          []
      end

    hand_struct(point, :fullhouse)
  end

  defp flush_from(cards) do
    cards
    |> all_cards_with(&Card.same_suit?/2)
    |> hand_struct(:flush)
  end

  defp straight_from(cards) do
    cards
    |> Card.sort_by_rank()
    |> all_cards_with(&Card.consecutive_rank?/2)
    |> hand_struct(:straight)
  end

  defp three_of_kind_from(cards) do
    cards
    |> group_cards_by_same_rank()
    |> with_a_number_of_cards(3)
    |> hand_struct(:three_of_kind)
  end

  defp two_pair_from(cards) do
    cards
    |> group_cards_by_same_rank()
    |> with_a_number_of_cards(2)
    |> with_total_number_of_cards(4)
    |> hand_struct(:two_pair)
  end

  defp one_pair_from(cards) do
    cards
    |> group_cards_by_same_rank()
    |> with_a_number_of_cards(2)
    |> hand_struct(:one_pair)
  end

  defp highest_card(cards) do
    high_card = Card.highest_card(cards)

    hand_struct([high_card], :high_card)
  end

  defp hand_struct(point, name) do
    %{name: name, point: point}
  end

  defp with_a_number_of_cards(cards_grouped_by_rank, number_of_cards) do
    cards_grouped_by_rank
    |> Enum.filter(fn cards -> length(cards) == number_of_cards end)
    |> Enum.concat()
  end

  defp with_total_number_of_cards(cards, number_of_cards) do
    case length(cards) do
      ^number_of_cards ->
        cards

      _ ->
        []
    end
  end

  defp group_cards_by_same_rank(cards) do
    cards
    |> Enum.group_by(fn %{rank: rank} -> rank end)
    |> Enum.map(fn {_, cards_with_same_rank} -> cards_with_same_rank end)
  end

  defp all_cards_with(cards, compare) do
    all_matches? =
      cards
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.all?(fn [card, next_card] -> compare.(card, next_card) end)

    case all_matches? do
      true -> cards
      false -> []
    end
  end

  def query(%{cards: cards}) do
    list_ranks = [
      straight_flush_from(cards),
      four_of_kind_from(cards),
      fullhouse_from(cards),
      flush_from(cards),
      straight_from(cards),
      three_of_kind_from(cards),
      two_pair_from(cards),
      one_pair_from(cards),
      highest_card(cards)
    ]

    list_ranks
    |> fetch_result()
  end

  defp fetch_result([]) do
    nil
  end

  defp fetch_result([head | tail]) do
    case head.point != [] do
      true ->
        head

      _ ->
        fetch_result(tail)
    end
  end
end
