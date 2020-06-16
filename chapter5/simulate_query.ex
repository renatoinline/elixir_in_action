defmodule SimulateQuery do
    def run_query(query_def) do
        Process.sleep(2000)
        "#{query_def} result"
    end

    def async_query(query_def) do
        caller = self()
        #spawn(fn -> IO.puts(run_query(query_def)) end)
        spawn(fn -> 
            send(caller, {:query_result, run_query(query_def)})
        end)
    end

    def receive_result() do
        receive do
            {:query_result, result} -> result
        after 
            5000 -> IO.puts("message not received")
        end
    end
end

# 1..5 |> Enum.map(&SimulateQuery.async_query("query #{&1}")) |> Enum.map(fn _ -> SimulateQuery.receive_result() end)