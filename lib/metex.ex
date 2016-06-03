defmodule Metex do
  def temperatures_of(cities) do
    coordinator_pid = spawn(Metex.Coordinator, :tick, [[], Enum.count(cities)])

    cities
    |> Enum.each fn city ->
      worker_pid = spawn(Metex.Worker, :tick, [])
      send(worker_pid, {coordinator_pid, city})
    end
  end
end
