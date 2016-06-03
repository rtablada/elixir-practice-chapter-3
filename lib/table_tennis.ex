defmodule Metex.TableTennis do
  def listen_for_ping(max_hits) do
    receive do
      {sender, "ping", hits} when hits < max_hits ->
        IO.puts "Heard ping"
        send(sender, {self, "pong", hits + 1})
        listen_for_ping(max_hits)
      _ ->
        listen_for_ping(max_hits)
    end
  end

  def listen_for_pong(max_hits) do
    receive do
      {sender, "pong", hits} when hits < max_hits ->
        IO.puts "Heard pong"
        send(sender, {self, "ping", hits + 1})
        listen_for_pong(max_hits)
      _ ->
        listen_for_pong(max_hits)
    end
  end

  def start(max_hits) do
    # loop_pid = spawn(Metex.TableTennis, :loop, [0, total_pings])
    pinger = spawn(Metex.TableTennis, :listen_for_ping, [max_hits])
    ponger = spawn(Metex.TableTennis, :listen_for_pong, [max_hits])

    # send(pinger, {ponger, "ping"})
    send(ponger, {pinger, "pong", 0})
  end
end
