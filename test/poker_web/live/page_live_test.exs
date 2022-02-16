defmodule PokerWeb.PageLiveTest do
  use ExUnit.Case, async: true
  alias Poker.Card

  describe "Player wins" do
    test "prints name and hand" do
      output = Card.play("Black", "2H 3D 5S 9C KD", "White", "2C 3H 4S 8C AH")

      assert output == "Winner is White. (high card of ace hearts)"
    end
  end

  describe "Player wins high card level 3" do
    test "prints name and hand" do
      output = Card.play("Black", " JH TH 8S AD 6H", "White", "AC JD TH 3C 9H")

      assert output == "Winner is White. (high card of 9 hearts)"
    end
  end

  describe "Player wins high card level 1" do
    test "prints name and hand" do
      output = Card.play("Black", "2H 3D 5S 9C KD", "White", "2C 3H 4S TC KH")

      assert output == "Winner is White. (high card of ten clubs)"
    end
  end

  describe "Player wins with one pair" do
    test "prints name and hand" do
      output = Card.play("Black", " 6D QD 7S TH 4S", "White", " 8S QC KS 8D 7C")

      assert output == "Winner is White. (one pair)"
    end
  end

  describe "Player wins with two pairs" do
    test "prints name and hand" do
      output = Card.play("Black", " 4D 3C 6H 5D 3H", "White", " 8C 2H 8C 2D 9H")

      assert output == "Winner is White. (two pair)"
    end
  end

  describe "Player wins with three of a kind" do
    test "prints name and hand" do
      output = Card.play("Black", " 8H KH 4H KC KC", "White", "KC KC TS AH 7H")

      assert output == "Winner is Black. (three of kind)"
    end
  end

  describe "Player wins with straight" do
    test "prints name and hand" do
      output = Card.play("Black", " 8H 6H 5H 7C 4D", "White", "KC QC TS AH 7H")

      assert output == "Winner is Black. (straight)"
    end
  end

  describe "Player wins flush" do
    test "prints name and hand" do
      output = Card.play("Black", "2H 4S 4C 3D 4H", "White", "2S 8S AS QS 3S")

      assert output == "Winner is White. (flush)"
    end
  end

  describe "Player wins fullhouse" do
    test "prints name and hand" do
      output = Card.play("Black", "2H 4S 4C 3D 4H", "White", "2S 8S AS QS 3S")

      assert output == "Winner is White. (flush)"
    end
  end

  describe "Player wins with four of a kind" do
    test "prints name and hand" do
      output = Card.play("Black", " JD JC JS JH 5C", "White", " QS AS 2D 7H 3H")

      assert output == "Winner is Black. (four of kind)"
    end
  end

  describe "Player wins with straight flush" do
    test "prints name and hand" do
      output = Card.play("Black", " KS 9S 7S 2D 8S", "White", " 4C 2C 3C 5C 6C")

      assert output == "Winner is White. (straight flush)"
    end
  end

  describe "when a game is tied" do
    test "prints out tie" do
      output = Card.play("Black", "2H 3D 5S 9C KD", "White", "2D 3H 5C 9S KH")

      assert output == "tie"
    end
  end
  
    describe "simulate random games" do
    test "prints out result" do
      Enum.map(
        0..1000,
        fn _x ->
      output = Card.play("Black", PageLive.random_one(), "White", PageLive.random_two())
      IO.puts assert output

        end
       )

    end
  end
end
