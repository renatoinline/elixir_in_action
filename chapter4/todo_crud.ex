defmodule MultiDict do
    def new(), do: %{}

    def add(dict, key, value) do
        Map.update(dict, key, [value], &[value | &1])
    end

    def get(dict, key) do
        Map.get(dict, key, [])
    end
end

defmodule TodoList do

    defstruct auto_id: 1, entries: %{}

    def new(entries \\ []) do
        Enum.reduce(
            entries,
            %TodoList{},
            &add_entry(&2, &1)
        )
    end

    def add_entry(todo_list, entry) do
        entry = Map.put(entry, :id, todo_list.auto_id)

        new_entries = Map.put(todo_list.entries, todo_list.auto_id, entry)

        %TodoList{ todo_list | 
            auto_id: todo_list.auto_id + 1, 
            entries: new_entries 
        }
    end

    def entries(todo_list, date) do
        todo_list.entries
        |> Stream.filter(fn {_, entry} -> entry.date == date end)
        |> Enum.map(fn {_, entry} -> entry end)
    end

    def update_entry(todo_list, entry_id, updater_fun) do
        case Map.fetch(todo_list.entries, entry_id) do
            :error ->
                todo_list

            {:ok, old_entry} -> 
                old_entry_id = old_entry.id
                new_entry = %{id: ^old_entry_id} = updater_fun.(old_entry)
                new_entries = Map.put(todo_list.entries, new_entry.id, new_entry)
                %TodoList{todo_list | entries: new_entries}
        end
    end

    def update_entry(todo_list, %{} = new_entry) do
        update_entry(todo_list, new_entry.id, fn _ -> new_entry end)
    end

    def delete_entry(todo_list, entry_id) do
        new_entries = Map.delete(todo_list.entries, entry_id)
        %TodoList{todo_list | entries: new_entries}
    end
end

defmodule TodoList.CsvImporter do
    def import(path) do
        base_path = "C:\\projetos\\Elixir In Action\\elixir_in_action\\chapter4"
        complete_path = "#{base_path}/#{path}"

        entries = complete_path
        |> read_file()
        |> parse_to_tuples()
        |> parse_date()
        |> parse_entries()
        |> Enum.to_list()

        TodoList.new(entries)
    end

    defp read_file(path) do
        path
        |> File.stream!()
        |> Stream.map(&String.replace(&1, "\n", ""))
    end

    defp parse_to_tuples(lines) do        
        lines
        |> Stream.map(fn line -> String.split(line, ",") |> List.to_tuple() end)
    end

    defp parse_date(tuples) do
        tuples
        |> Stream.map(
            fn {date, desc} -> 
                
                list = 
                String.split(date, "/") 
                |> Enum.map(fn part -> String.to_integer(part) end)
                
                {result, date} = List.to_tuple(list)
                |> Date.from_erl()

                if result == :ok do
                    {date, desc}    
                else
                    {Date.utc_today(), desc}
                end
                
            end)
    end        

    defp parse_entries(tuples) do
        tuples
        |> Stream.map(fn {date, desc} -> %{date: date, title: desc} end)        
    end
end
