# 6.1.5 Exercise: refactoring the to-do server
# chapter 6 exercise: todo server using genserver

defmodule TodoEntry do
    defstruct id: 0, date: nil, title: nil
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

defmodule TodoServer do
    use GenServer

    # interface methods
    def start do
        GenServer.start(__MODULE__, nil, name: __MODULE__)
    end

    def stop do
        Genserver.stop(__MODULE__, :normal)
    end

    def add_entry(%TodoEntry{} = new_entry) do
        GenServer.cast(__MODULE__, {:add_entry, new_entry})
    end

    def entries(date) do
       GenServer.call(__MODULE__, {:entries, date});        
    end

    def update_entry(%TodoEntry{} = new_entry) do
        GenServer.cast(__MODULE__, {:update_entry, new_entry})
    end

    def delete_entry(entry_id) do 
        GenServer.cast(__MODULE__, {:delete_entry, entry_id})
    end 
    
    # server methods
    @impl GenServer
    def init(_) do
        {:ok, TodoList.new()}
    end

    @impl GenServer
    def handle_call({:entries, date}, _, state) do
        {:reply, TodoList.entries(state, date), state}    
    end

    @impl GenServer
    def handle_cast({:add_entry, new_entry}, state) do
        {:noreply, TodoList.add_entry(state, new_entry)}
    end
    
    @impl GenServer
    def handle_cast({:update_entry, new_entry}, state) do
        {:noreply, TodoList.update_entry(state, new_entry)}
    end

    @impl GenServer
    def handle_cast({:delete_entry, entry_id}, state) do
        {:noreply, TodoList.delete_entry(state, entry_id)}
    end
end