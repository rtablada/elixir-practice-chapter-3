defmodule Metex.TableTennis do
  def listen_for_ping(skillz) do
    receive do
      # Check if message matches format with "ping" and current volley count
      {opponent, "ping", volley} when volley < skillz ->
        IO.puts "Heard ping"
        send(opponent, {self, "pong", volley + 1})

        # Set the listener process back up to listen for the next hit!
        # Without this, only one volley will ever happen
        listen_for_ping(skillz)
      # If the received message is anything else, setup to listen again
      _ ->
        listen_for_ping(skillz)
    end
  end

  def listen_for_pong(skillz) do
    receive do
      # Check if message matches format with "pong" and current volley count
      {opponent, "pong", volley} when volley < skillz ->
        IO.puts "Heard pong"
        send(opponent, {self, "ping", volley + 1})

        # Set the listener process back up to listen for the next hit!
        # Without this, only one volley will ever happen
        listen_for_pong(skillz)
      # If the received message is anything else, setup to listen again
      _ ->
        listen_for_pong(skillz)
    end
  end

  def start(skillz) do
    # Spawns a process that listens for ping
    pinger = spawn(Metex.TableTennis, :listen_for_ping, [skillz])
    # Spawns a process that listens for pong
    ponger = spawn(Metex.TableTennis, :listen_for_pong, [skillz])

    # Sends a message to the pong listener with
    #   - Ping listener
    #   - Pong message
    #   - 0 volley number
    send(ponger, {pinger, "pong", 0})

    # Sends a message to the pong listener with
    #   - Ping listener
    #   - Pong message
    #   - 0 volley number
    #
    #   This message should be pretty much ignored...
    #   But might lead to an endless worker loop?
    send(ponger, {pinger, "ping", 0})
  end
end
