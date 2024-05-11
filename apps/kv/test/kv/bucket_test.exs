defmodule KV.BucketTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, bucket} = KV.Bucket.start_link([])

    {:ok, %{bucket: bucket}}
  end

  test "stores values by key", %{bucket: bucket} do
    assert KV.Bucket.get(bucket, "milk") == nil

    assert KV.Bucket.put(bucket, "milk", 4)
    assert KV.Bucket.get(bucket, "milk") == 4
  end

  test "deletes a key", %{bucket: bucket} do
    assert KV.Bucket.put(bucket, "milk", 4)
    assert KV.Bucket.delete(bucket, "milk")
    assert Agent.get(bucket, fn map -> map end) == %{}
  end

  test "are temporary workers" do
    assert Supervisor.child_spec(KV.Bucket, []).restart == :temporary
  end
end
