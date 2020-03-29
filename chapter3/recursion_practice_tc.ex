defmodule RecursionTC do
    @doc """
    A module for practicing tail call functions and recursion

    * A list_len/1 function that calculates the length of a list
    * A range/2 function that takes two integers, from and to, and returns a list of all numbers in the given range
    * A positive/1 function that takes a list and returns another list that contains only the positive numbers from the input list

    """
    def list_len(list) do
        list_len_recursion(0, list)
    end

    defp list_len_recursion(length, []) do
        length # stop recursion
    end

    defp list_len_recursion(length, [_ | tail]) do
        new_length = 1 + length
        list_len_recursion(new_length, tail)
    end


    def range(a, b) do
        Enum.reverse(range_recursion([], a, b))
    end

    defp range_recursion(list, a, b) when a == b do
        [a | list] # stop recursion
    end

    defp range_recursion(list, a, b) do
        new_list = [a | list]
        new_a = a + 1;
        range_recursion(new_list, new_a, b)
    end


    def positive(list) do
        Enum.reverse(positive_recursion([], list))
    end
    
    defp positive_recursion(list_positives, []) do
        list_positives #stop recursion
    end

    defp positive_recursion(list_positives, [head | tail]) do
        
        if head > 0 do
            new_list_positives = [head | list_positives]
            positive_recursion(new_list_positives, tail)
        else
            positive_recursion(list_positives, tail)
        end

    end    
end