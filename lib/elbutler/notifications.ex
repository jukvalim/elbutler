defmodule ElButler.Notifications do
  @notify_title "ElButler"

  def say(message) when is_binary(message) do
    System.cmd("say", [message])
  end

  def notify(message) when is_binary(message) do
    cmd = ~s|display notification "#{message}" with title "#{ @notify_title }"|
    System.cmd("/usr/bin/osascript", ["-e", cmd])
  end

end
