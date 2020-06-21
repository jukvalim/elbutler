import Config

config :logger,
  level: :debug

config :elbutler, ElButler.Scheduler,
  timezone: "Europe/Helsinki",
  jobs: [
    # {"@hourly", fn -> ElButler.Tasks.check_worth_the_candle() end},
    {"@hourly", {ElButler.Tasks, :check_worth_the_candle, []}},
    # {"@hourly", fn -> ElButler.Tasks.check_hoc() end},
    {"@hourly", {ElButler.Tasks, :check_hoc, []}},
    # {"@hourly", fn -> ElButler.Tasks.check_pod() end}
    {"@hourly", {ElButler.Tasks, :check_pod, []}}
    # {"* * * * *",      fn ->  System.cmd("say", [("minute " <> Integer.to_string DateTime.utc_now().minute)]) end},
    # {{:extended, "* * * * *"}, fn -> System.cmd("say", [Integer.to_string DateTime.utc_now().second]) end},
    # Every minute
    # {"* * * * *",      fn -> System.cmd("rm", ["/tmp/tmp_"]) end},
    # # Every 15 minutes
    # {"*/15 * * * *",   fn -> System.cmd("rm", ["/tmp/tmp_"]) end},
    # # Runs on 18, 20, 22, 0, 2, 4, 6:
    # {"0 18-6/2 * * *", fn -> :mnesia.backup('/var/backup/mnesia') end},
    # # Runs every midnight:
    # {"@daily",         {Backup, :backup, []}}
  ]

import_config "#{Mix.env()}.exs"
