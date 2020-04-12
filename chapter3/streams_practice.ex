defmodule StreamsPractice do
    @moduledoc """    
    A module for Practice section

    * A lines_lengths!/1 that takes a file path and returns a list of numbers, with
    each number representing the length of the corresponding line from the file.

    * A longest_line_length!/1 that returns the length of the longest line in a file.

    * A longest_line!/1 that returns the contents of the longest line in a file.

    * A words_per_line!/1 that returns a list of numbers, with each number rep-
    resenting the word count in a file. Hint: to get the word count of a line, use
    length(String.split(line)) 

    path:     
    C:\\projetos\\Elixir In Action\\elixir_in_action\\chapter3\\file\\alice's_adventures_in_wonderland _chapter_01.txt
    """

    @doc """
    Sample provide in the book
    """
    def large_lines!(path) do        
        File.stream!(path)
        |> Stream.map(&String.replace(&1, "\n", ""))
        |> Enum.filter(&(String.length(&1) > 80))
    end

    @doc """
    A lines_lengths!/1 that takes a file path and returns a list of numbers, with
    each number representing the length of the corresponding line from the file.
    """
    def lines_lengths!(file_path) do
        File.stream!(file_path)
        |> Stream.map(&String.replace(&1, "\n", ""))
        |> Enum.map(&(String.length/1))
    end

    @doc """
    A longest_line_length!/1 that returns the length of the longest line in a file.
    """
    def longest_line_length!(file_path) do
        File.stream!(file_path)
        |> Stream.map(&String.replace(&1, "\n", ""))
        |> Stream.map(&String.length/1)
        |> Enum.max()
    end

    @doc """
    A longest_line!/1 that returns the contents of the longest line in a file.
    """
    def longest_line!(file_path) do
        File.stream!(file_path)
        |> Stream.map(&String.replace(&1, "\n", ""))
        |> Enum.max_by(&String.length/1)
    end

    def words_per_line!(file_path) do
        File.stream!(file_path)
        |> Enum.map(&word_count/1)
    end

    defp word_count(string) do
        string
        |> String.split()
        |> length()
    end

end