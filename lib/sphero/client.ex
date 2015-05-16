defmodule Sphero.Client do
  defmodule State do
    defstruct [:device, :seq]
  end

  use ExActor.GenServer

	##### Dan Edits

	defcall heading(heading), state: state do
		do_request(Sphero.Command.Heading.new(seq: state.seq, heading: heading), state)
	end

	defcall set_stabil(flag), state: state do
		do_request(Sphero.Command.SetStabilization.new(seq: state.seq, flag: <<flag>>), state)
	end

	defcall self_level(start_stop, final_angle, sleep, control_system, anglelim, timeout, truetime),
	state: state do
		options = <<start_stop :: size(2), final_angle :: size(2) ,sleep :: size(2) ,control_system :: size(2)>>
			data = options <> <<anglelim>> <> <<timeout>> <> <<truetime>>
		do_request(Sphero.Command.SelfLevel.new(seq: state.seq, data: data), state)
	end
	
	#####

	
  defcall ping, state: state do
    do_request(Sphero.Request.Ping.new(seq: state.seq), state)
  end

  defcall set_rgb(red, green, blue), state: state do
    persistent = 0
    do_request(Sphero.Command.SetRGB.new(seq: state.seq, data: <<red, green, blue, persistent>>), state)
  end

  defcall roll(speed, heading), state: state do
    do_request(Sphero.Command.Roll.new(seq: state.seq, speed: speed, heading: heading, delay: 1), state)
  end

  defcall stop, state: state do
    do_request(Sphero.Command.Roll.new(seq: state.seq, speed: 0, heading: 0, delay: 1), state)
  end

  defstart start(device) do
    device = :serial.start([speed: 115200, open: :erlang.bitstring_to_list(device)])
    initial_state(%State{device: device, seq: 0})
  end

  defp do_request(request, state) do
    request_bytes = Sphero.Request.to_string(request)
    IO.inspect request_bytes
    send(state.device, {:send, request_bytes})
    # receive 5 integers FIXME: Only doing 1 right now
    _response = receive do
      {:data, data} -> IO.inspect data
    after
      1 -> :timeout
    end
    # update the seq
    state = %State{state | seq: state.seq + 1}
    set_and_reply(state, :ok)
  end
end
