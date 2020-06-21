import Config

config :elbutler, :telegram_token, System.fetch_env!("TELEGRAM_TOKEN")
config :elbutler, :telegram_chat_id, System.fetch_env!("TELEGRAM_CHAT_ID")
