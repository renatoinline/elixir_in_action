defmodule Recursion do
    @doc """
    A module for practicing recursion

    * A list_len/1 function that calculates the length of a list
    * A range/2 function that takes two integers, from and to, and returns a list of all numbers in the given range
    * A positive/1 function that takes a list and returns another list that contains only the positive numbers from the input list

    """

    def list_len([]), do: 0
    def list_len([_ | tail]), do: 1 + list_len(tail)

    def range(a, b) when  a == b, do: [b]
    def range(a, b), do: [a | range(a+1, b)]
    
    def positive([]), do: []
    def positive([head | tail]) do
        if head > 0, do: [head | positive(tail)], else: positive(tail)
    end
end