import Config


config :logger,
  level: :debug

config :elbutler, ElButler.Scheduler,
  timezone: "Europe/Helsinki",
  jobs: [
    {"@hourly", fn -> ElButler.Tasks.check_mother_of_learning(102) end},
    {"@hourly", fn -> ElButler.Tasks.check_worth_the_candle(183) end},
    #{"* * * * *", fn -> ElButler.Tasks.check_mother_of_learning(101) end},
    #{"* * * * *",      fn ->  System.cmd("say", [("minute " <> Integer.to_string DateTime.utc_now().minute)]) end},
    {{:extended, "* * * * *"}, fn -> System.cmd("say", [Integer.to_string DateTime.utc_now().second]) end},
    # Every minute
    # {"* * * * *",      fn -> System.cmd("rm", ["/tmp/tmp_"]) end},
    # # Every 15 minutes
    # {"*/15 * * * *",   fn -> System.cmd("rm", ["/tmp/tmp_"]) end},
    # # Runs on 18, 20, 22, 0, 2, 4, 6:
    # {"0 18-6/2 * * *", fn -> :mnesia.backup('/var/backup/mnesia') end},
    # # Runs every midnight:
    # {"@daily",         {Backup, :backup, []}}
  ]

#config :elbutler, Elbutler.TaskData,
#   last_mol_chapter = 102,
#   last_wtc_chapter 183

