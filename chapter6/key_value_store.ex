defmodule KeyValueStore do
  use GenServer
  
  @impl GenServer  
  def init(_) do
    :timer.send_interval(10000, :cleanup)
    {:ok, %{}}
  end

  @impl GenServer  
  def handle_cast({:put, key, value}, state) do
    {:noreply, Map.put(state, key, value)}
  end

  @impl GenServer  
  def handle_call({:get, key}, _, state) do
    {:reply, Map.get(state, key), state}
  end

  @impl GenServer  
  def handle_info(:cleanup, state) do
    clean(state)
  end

  defp clean(state) when state == %{}, do: {:noreply, %{}}
  defp clean(state) do
    c = Enum.count(state)
    if c > 5, do: IO.puts("performing cleanup")
    if c > 5, do: {:noreply, %{}}, else: {:noreply, state}
  end

  # interface functions

  def start do
    GenServer.start(__MODULE__, nil, name: __MODULE__)
  end

  def stop do
    GenServer.stop(__MODULE__, :normal)
  end

  def put(key, value) do
    GenServer.cast(__MODULE__, {:put, key, value})
  end

  def get(key) do
    GenServer.call(__MODULE__, {:get, key})
  end
end