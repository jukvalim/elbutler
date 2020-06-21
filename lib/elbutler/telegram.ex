defmodule ElButler.Telegram.Notifications do
  def notify(message) when is_binary(message) do
    token = Application.fetch_env!(:elbutler, :telegram_token)
    chat_id = Application.fetch_env!(:elbutler, :chat_id)

    Telegram.Api.request(token, "sendMessage",
      chat_id: chat_id,
      text: message
    )
  end
end
