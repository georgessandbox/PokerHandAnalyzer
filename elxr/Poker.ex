#code inspired by wojtekmach
defmodule Poker do
bo
  def deal (hands) do

    frst = Enum.take_every( hands , 2)
    scnd = hands -- frst |> Enum.map(&parse_card/1) |> sort_hand()
    frst = frst          |> Enum.map(&parse_card/1) |> sort_hand()

    r = hand_value(frst) - hand_value(scnd)

    win1 =   Tuple.to_list(frst)|> Enum.map(fn {a,d} -> if a == 14 do {1,d} else {a,d} end end )
             |> Enum.sort_by(fn {rank,_} -> rank end) |> Enum.map(fn {a,b} -> Integer.to_string(a) <> Atom.to_string(b) end)

    win2 =   Tuple.to_list(scnd)|> Enum.map(fn {a,d} -> if a == 14 do {1,d} else {a,d} end end )
             |> Enum.sort_by(fn {rank,_} -> rank end) |> Enum.map(fn {a,b} -> Integer.to_string(a) <> Atom.to_string(b) end)

    cond do
      r > 0  ->  IO.inspect(win1)
      r == 0 -> IO.inspect(win2)
      r < 0  -> IO.inspect(win2)
    end
  end

  def hand_value(hand) do
    value = [C: 1, D: 2, H: 3, S: 4]
    suit = fn x -> Keyword.fetch!(value, x) end
    case hand_rank(hand) do
      {:royal_flush, s1}              -> 9_0000 + suit.(s1)
      {:straight_flush, a, s1}        -> 8_0000 + a * 100 + suit.(s1)
      {:four_of_a_kind, a,_}          -> 7_0000 + a * 150
      {:full_house, a,_}              -> 6_0000 + a * 150
      {:flush, a, b, c, d, e , s}     -> 5_0000 + a * 100 + b * 30 + c * 4 + d * 0.005 + e * 0.00005 + suit.(s) * 0.000005
      {:straight, a, s}               -> 4_0000 + a * 10 + suit.(s)
      {:three_of_a_kind, a,_,_}       -> 3_0000 + a * 200
      {:two_pair, a, b, c,s1,s2}      -> 2_0000 + a * 200 + b * 25 + c * 3 + (if  suit.(s1) > suit.(s2) do suit.(s1) * 0.005   else suit.(s2) * 0.005 end )
      {:one_pair, a, b, c, d,s1,s2}   -> 1_0000 + a * 200 + b * 25 + c * 3 + d * 0.005 + (if  suit.(s1) > suit.(s2) do suit.(s1) * 0.00005   else suit.(s2) * 0.00005 end )
      {:high_card, a, b, c, d, e, s1} ->          a * 200 + b * 25 + c * 3 + d * 0.005 + e * 0.00005 + suit.(s1) * 0.000005
end
  end

  def hand_rank(hand) do
    if is_straight(hand) do
      {{r1,s1}, {r2,s2}, _, _, _} = hand

      {r,s} = if r1 == 14 && r2 == 5 do   {r2,s2}
                                 else {r1,s1} end

      if is_flush(hand) do
        if (r1 == 14) && (r2 == 13) do {:royal_flush, s1} else
        {:straight_flush, r, s} end else {:straight, r , s} end

    else
      case hand do
        {{a,_},  {a,_},  {a,_},  {a,_},  {b,_}}  -> {:four_of_a_kind, a,b}
        {{b,_},   {a,_},  {a,_},  {a,_},  {a,_}} -> {:four_of_a_kind, a,b}

        {{a,_},  {a,_},  {a,_},  {b,_},  {b,_}}  -> {:full_house, a,b}
        {{b,_},  {b,_},  {a,_},  {a,_},  {a,_}}  -> {:full_house, a,b}

        {{r1,a}, {r2,a}, {r3,a}, {r4,a}, {r5,a}}   -> {:flush, r1, r2, r3, r4, r5 , a}

        {{a,_},  {a,_},  {a,_},  {b,_},  {c,_}}  -> {:three_of_a_kind, a, b, c}
        {{b,_}, {a,_},  {a,_},   {a,_},  {c,_}}  -> {:three_of_a_kind, a, b, c}
        {{b,_}, {c,_}, {a,_},    {a,_},  {a,_}}  -> {:three_of_a_kind, a, b, c}

        {{a,s1},  {a,s2},  {b,_},  {b,_},  {c,_}}  -> {:two_pair, a, b, c, s1, s2}
        {{b,s1},  {b,s2},  {c,_}, {a,_},  {a,_}}   -> {:two_pair, a, b, c, s1, s2}
        {{c,_},  {a,s1},  {a,s2},  {b,_},  {b,_}}  -> {:two_pair, a, b, c, s1, s2}

        {{a,s1},  {a,s2},  {b,_},  {c,_},  {d,_}}  -> {:one_pair, a, b, c, d,s1,s2}
        {{b,_},  {a,s1},  {a,s2},  {c,_},  {d,_}}  -> {:one_pair, a, b, c, d,s1,s2}
        {{b,_},  {c,_},  {a,s1},  {a,s2},  {d,_}}  -> {:one_pair, a, b, c, d,s1,s2}
        {{b,_},  {c,_},  {d,_},  {a,s1},  {a,s2}}  -> {:one_pair, a, b, c, d,s1,s2}

        {{a,s1},  {b,_},  {c,_},  {d,_},  {e,_}}  -> {:high_card, a, b, c, d, e,s1}
      end
    end
   end

  def is_straight({{a,_}, {b,_}, {c,_}, {d,_}, {e,_}}) do
    (a == 14 && b == 5 && c == 4 && d == 3 && e == 2 ) ||
     a == b+1 && b == c+1 && c == d+1 && d==e+1
  end

  defp is_flush({{_,a},{_,a},{_,a},{_,a},{_,a}}), do: true
  defp is_flush({_,_,_,_,_}),                     do: false

  def parse_card(num) do
    case num do
      num when num in 1..13 ->  {if num == 1  do 14 else num      end , :C}
      num when num in 14..26 -> {if num == 14 do 14 else num - 13 end , :D}
      num when num in 27..39 -> {if num == 27 do 14 else num - 26 end , :H}
      num when num in 40..52 -> {if num == 40 do 14 else num - 39 end , :S}
    end
  end

  defp sort_hand(hand) do
    hand
    |> Enum.sort_by(fn {rank,_} -> rank end)
    |> Enum.reverse
    |> List.to_tuple
  end

end

