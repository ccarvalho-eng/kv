defmodule KVServer.Command do
  @moduledoc false

  alias KV.{Bucket, Registry}

  @spec parse(String.t()) :: tuple()
  def parse(line) do
    case String.split(line) do
      ["CREATE", bucket] -> {:ok, {:create, bucket}}
      ["GET", bucket, key] -> {:ok, {:get, bucket, key}}
      ["PUT", bucket, key, value] -> {:ok, {:put, bucket, key, value}}
      ["DELETE", bucket, key] -> {:ok, {:delete, bucket, key}}
      _ -> {:error, :unknown_command}
    end
  end

  @spec run(tuple()) :: {:ok, term()} | {:error, term()}
  def run({:create, bucket}) do
    Registry.create(Registry, bucket)
    {:ok, "OK\r\n"}
  end

  def run({:get, bucket, key}) do
    lookup(bucket, fn pid ->
      value = Bucket.get(pid, key)
      {:ok, "#{value}\r\n\OK\r\n"}
    end)
  end

  def run({:put, bucket, key, value}) do
    lookup(bucket, fn pid ->
      Bucket.put(pid, key, value)
      {:ok, "OK\r\n"}
    end)
  end

  def run({:delete, bucket, key}) do
    lookup(bucket, fn pid ->
      Bucket.delete(pid, key)
      {:ok, "OK\r\n"}
    end)
  end

  defp lookup(bucket, callback_fn) do
    case Registry.lookup(Registry, bucket) do
      {:ok, pid} ->
        callback_fn.(pid)

      :error ->
        {:error, :not_found}
    end
  end
end
