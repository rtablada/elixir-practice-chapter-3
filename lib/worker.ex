defmodule Metex.Worker do

  def tick do
    receive do
      {sender_pid, location} ->
        send(sender_pid, {:ok, temperature_of(location)})
      sender_pid ->
        send(sender_pid, "Unknown message")
    end
    tick
  end

  def temperature_of(loc) do
    result = url_for(loc)
            |> HTTPoison.get
            |> parse_response

    case result do
      {:ok, temp} ->
        "#{loc}: #{temp}ºC"
      :error ->
        "#{loc} not found"
    end
  end

  defp url_for(loc) do
    appid = Application.get_env(:metex, :appid)

    "http://api.openweathermap.org/data/2.5/weather?q=#{loc}&appid=#{appid}"
  end

  defp parse_response({:ok, %HTTPoison.Response{body: body, status_code: 200}}) do
    body
    |> JSON.decode!
    |> compute_temperature
  end

  defp parse_response(_) do
    :error
  end

  defp compute_temperature(json) do
    try do
      temp = (json["main"]["temp"] - 274.15)
      |> Float.round(1)

      {:ok, temp}
    rescue
      _ -> :error
    end
  end
end
