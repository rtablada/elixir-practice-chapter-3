defmodule Metex.Coordinator do
  def tick(results \\ [], results_expetcted) do
    receive do
      {:ok, result} ->
        # Prepends the result to the list
        new_results = [result | results]

        if results_expetcted == Enum.count(new_results) do
          send(self, :exit)
        end

        tick(new_results, results_expetcted)
      :exit ->
        results
        |> Enum.sort
        |> Enum.join(", ")
        |> IO.puts
      _ ->
        tick(results, results_expetcted)
    end
  end
end
