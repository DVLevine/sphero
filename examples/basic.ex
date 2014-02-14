defmodule Examples.Basic do
  alias Sphero.Client, as: C

  def start(device) do
    {:ok, s} = C.start(device)
    rotate_through(s, 20)
  end

  defp values do
    Stream.repeatedly(fn() -> :erlang.round(:random.uniform() * 255) end)
  end
  defp rotate_through(_pid, 0), do: :ok
  defp rotate_through(pid, n) do
    [red, green, blue] = values |> Enum.take(3)
    pid |> C.set_rgb(red, green, blue)
    :erlang.sleep(100)
    rotate_through(pid, n-1)
  end
end
