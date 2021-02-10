defmodule Todo.Server do
  use GenServer

  # interface methods
  def start do
      GenServer.start(__MODULE__, nil, name: __MODULE__)
  end

  def stop do
      Genserver.stop(__MODULE__, :normal)
  end

  def add_entry(%Todo.Entry{} = new_entry) do
      GenServer.cast(__MODULE__, {:add_entry, new_entry})
  end

  def entries(date) do
     GenServer.call(__MODULE__, {:entries, date});        
  end

  def update_entry(%Todo.Entry{} = new_entry) do
      GenServer.cast(__MODULE__, {:update_entry, new_entry})
  end

  def delete_entry(entry_id) do 
      GenServer.cast(__MODULE__, {:delete_entry, entry_id})
  end 
  
  # server methods
  @impl GenServer
  def init(_) do
      {:ok, Todo.List.new()}
  end

  @impl GenServer
  def handle_call({:entries, date}, _, state) do
      {:reply, Todo.List.entries(state, date), state}    
  end

  @impl GenServer
  def handle_cast({:add_entry, new_entry}, state) do
      {:noreply, Todo.List.add_entry(state, new_entry)}
  end
  
  @impl GenServer
  def handle_cast({:update_entry, new_entry}, state) do
      {:noreply, Todo.List.update_entry(state, new_entry)}
  end

  @impl GenServer
  def handle_cast({:delete_entry, entry_id}, state) do
      {:noreply, Todo.List.delete_entry(state, entry_id)}
  end
end