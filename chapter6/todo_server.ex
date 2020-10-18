# 6.1.5 Exercise: refactoring the to-do server

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


defmodule ServerProcess do
    def start(callback_module) do
        spawn(fn ->
            initial_state = callback_module.init()
            loop(callback_module, initial_state)
        end)
    end

    def call(server_pid, request) do
        send(server_pid, {:call, request, self()})

        receive do
            {:response, response} ->
                response
        end
        
    end

    def cast(server_pid, request) do
        send(server_pid, {:cast, request})
    end

    defp loop(callback_module, current_state) do
            
        receive do
            {:call, request, caller} ->
                {response, new_state} = callback_module.handle_call(request, current_state)
                send(caller, {:response, response})
                loop(callback_module, new_state)
            {:cast, request} ->
                new_state = callback_module.handle_cast(request, current_state)
                loop(callback_module, new_state)
        end            

    end
end


defmodule TodoServer do
    
    # interface methods
    def start do
        ServerProcess.start(TodoServer)
        #spawn(fn -> loop(TodoList.new()) end)
    end

    def add_entry(todo_server, %TodoEntry{} = new_entry) do
        ServerProcess.cast(todo_server, {:add_entry, new_entry})
        #send(todo_server, {:add_entry, new_entry})
    end

    def entries(todo_server, date) do
       ServerProcess.call(todo_server, {:entries, date});
        #send(todo_server, {:entries, self(), date})

        #receive do
        #    {:todo_entries, entries} -> entries
        #after
        #    5000 -> {:error, :timeout}
        #end        
    end

    def update_entry(todo_server, %TodoEntry{} = new_entry) do
        ServerProcess.cast(todo_server, {:update_entry, new_entry})
        #send(todo_server, {:update_entry, new_entry})
    end

    def delete_entry(todo_server, entry_id) do 
        ServerProcess.cast(todo_server, {:delete_entry, entry_id})
        #send(todo_server, {:delete_entry, entry_id})
    end 
    
    # server methods

    def init do
        TodoList.new()
    end

    def handle_call({:entries, date}, state) do
        {TodoList.entries(state, date), state}
        #send(caller, {:todo_entries, TodoList.entries(todo_list, date)})
        #todo_list
    end

    def handle_cast({:add_entry, new_entry}, state) do
        TodoList.add_entry(state, new_entry)
    end
    
    def handle_cast({:update_entry, new_entry}, state) do
        TodoList.update_entry(state, new_entry)
    end

    def handle_cast({:delete_entry, entry_id}, state) do
        TodoList.delete_entry(state, entry_id)
    end

    # defp loop(todo_list) do
    #     new_todo_list = 
    #     receive do
    #         message -> process_message(todo_list, message)
    #     end
    #     loop(new_todo_list)
    # end
end