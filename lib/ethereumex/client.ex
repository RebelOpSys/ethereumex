defmodule Ethereumex.Client do
  @callback request(payload :: map) :: tuple
  @callback batch_request(payload :: list) :: tuple
  @moduledoc false

  alias Ethereumex.Client.Utils

  def compile_solidity(sol_code) do
    guid = UUID.uuid1()
    {:ok, file} = File.open guid <> ".sol", [:write]
    IO.binwrite file, sol_code
    file |> File.close

    System.cmd("solc", ["-o", "sol_output_#{guid}", "--bin", "--optimize", "--ast", "--asm", "--abi", "#{guid}.sol"])

    {:ok, abiFile} = "sol_output_#{guid}/*.abi" |> Path.wildcard |> Enum.at(0) |> File.open([:read])
   
    IO.puts "Compiled abi is:"

    abi = abiFile |> IO.read(:all) |> Poison.decode!
    abiFile |> File.close

    {:ok, binFile} = "sol_output_#{guid}/*.bin" |> Path.wildcard |> Enum.at(0) |> File.open
    bin = binFile |> IO.binread(:all)
    binFile |> File.close

    "sol_output_#{guid}" |> File.rm_rf
    "#{guid}.sol" |> File.rm_rf

    %{"abi" => abi, "bin"=>bin}
  end

  defmacro __using__(_) do
    methods = Utils.available_methods

    quote location: :keep, bind_quoted: [methods: methods] do
      @behaviour Ethereumex.Client
      use GenServer

      def start_link(id \\ 0) when is_number(id) do
        GenServer.start_link(__MODULE__, id, name: __MODULE__)
      end

      def reset_id do
        GenServer.cast __MODULE__, :reset_id
      end

      def handle_call({:request, params}, _from, id) do
        params  = params |> Map.put("id", id)

        response = request(params)

        {:reply, response, id + 1}
      end

      def handle_cast(:reset_id, _id) do
        {:noreply, 0}
      end

      methods
      |> Enum.each(fn({original_name, formatted_name}) ->
        def unquote(formatted_name)(params \\ []) when is_list(params) do
          params = params |> add_method_info(unquote(original_name))

          GenServer.call __MODULE__, {:request, params}
        end
      end)

      def request(_) do
      end

      def batch_request(_) do
      end

      defp add_method_info(params, method_name) do
        %{}
        |> Map.put("method", method_name)
        |> Map.put("jsonrpc", "2.0")
        |> Map.put("params", params)
      end

      defoverridable [request: 1, batch_request: 1]
    end
  end
end
