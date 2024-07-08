import Config

config :kv, :routing_table, [{?a..?z, node()}]

if config_env() == :prod do
  config :kv, :routing_table, [
    {
      {?a..?m, :"foo@DNM-A192"},
      {?n..?z, :"bar@DNM-A192"}
    }
  ]
end
