defmodule KV.Registry do
  use GenServer

  # client api
  def start_link(opts) do
    server = Keyword.fetch!(opts, :name)
    GenServer.start_link(__MODULE__, server, opts)
  end

  def lookup(server, name) do
    case :ets.lookup(server, name) do
      [{^name, pid}] ->
        {:ok, pid}

      _ ->
        :error
    end
  end

  def create(server, name) do
    GenServer.call(server, {:create, name})
  end

  # server api

  # callbacks
  @impl true
  def init(table) do
    names = :ets.new(table, [:named_table, read_concurrency: true])
    refs = %{}
    {:ok, {names, refs}}
  end

  # handle call, cast, info
  @impl true
  def handle_call({:create, name}, _from, {names, refs} = state) do
    case lookup(names, name) do
      {:ok, pid} ->
        {:reply, pid, state}

      :error ->
        {:ok, bucket} = DynamicSupervisor.start_child(KV.BucketSupervisor, KV.Bucket)
        ref = Process.monitor(bucket)
        refs = Map.put(refs, ref, name)
        :ets.insert(names, {name, bucket})
        {:reply, bucket, {names, refs}}
    end
  end

  @impl true
  def handle_info({:DOWN, ref, :process, _pid, _reason}, {names, refs}) do
    {name, refs} = Map.pop(refs, ref)
    :ets.delete(names, name)
    {:noreply, {names, refs}}
  end

  @impl true
  def handle_info(msg, state) do
    require Logger
    Logger.debug("Unexpected message in #{__MODULE__}: #{inspect(msg)}")

    {:noreply, state}
  end
end
