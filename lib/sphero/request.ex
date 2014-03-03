defmodule Sphero.Request do
  defstruct seq: nil, data: "", did: <<0>>, cid: <<0>>

  use Bitwise, only_operators: true

  def to_string(request) do
    packet_header(request) <> packet_body(request) <> checksum(request)
  end

  defp checksum(request) do
    csum = packet_header(request) <> packet_body(request)
             |> :binary.bin_to_list
             |> Enum.drop(2)
             |> sum
             |> rem(256)
    csumval = ~~~csum &&& 255
    <<csumval>>
  end

  defp header(request) do
    sop1 <>
    sop2 <>
    request.did <>
    request.cid <>
    <<request.seq>> <>
    :erlang.list_to_binary([dlen(request.data)])
  end

  defp sum(list), do: sum(list, 0)
  defp sum([head|rest], accum), do: sum(rest, accum + head)
  defp sum([], accum), do: accum

  defp packet_header(request), do: header(request)

  defp packet_body(request), do: request.data

  defp sop1, do: <<255>>
  defp sop2, do: <<255>>

  def dlen(data) do
    byte_size(data) + 1
  end
end

defmodule Sphero.Request.Ping do
  def new([seq: seq]), do: %Sphero.Request{seq: seq, cid: <<1>>}
end

defmodule Sphero.Request.GetVersioning do
  def new([seq: seq]), do: %Sphero.Request{ seq: seq, cid: <<2>> }
end

defmodule Sphero.Request.GetBluetoothInfo do
  def new([seq: seq]), do: %Sphero.Request{ seq: seq, cid: <<17>> }
end

defmodule Sphero.Request.SetAutoReconnect do
  def new([seq: seq]), do: %Sphero.Request{ seq: seq, cid: <<18>> }
end

defmodule Sphero.Request.GetAutoReconnect do
  def new([seq: seq]), do: %Sphero.Request{ seq: seq, cid: <<19>> }
end

defmodule Sphero.Request.GetPowerState do
  def new([seq: seq]), do: %Sphero.Request{ seq: seq, cid: <<32>> }
end

defmodule Sphero.Request.Sleep do
  def new([seq: seq, wakeup: wakeup, macro: macro]) do
    # Convert wakeup to an unsigned 16-bit packed integer
    %Sphero.Request{ seq: seq, data: <<macro, wakeup :: [unsigned, size(16)]>>, cid: <<34>> }
  end
end
