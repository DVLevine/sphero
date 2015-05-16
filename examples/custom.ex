defmodule Examples.Custom do
	alias Sphero.Client, as: C

	def start_and_stuff() do
		{:ok, s} = C.start("/dev/tty.Sphero-YWY-AMP-SPP")
		{:connection, s}
	end
	
	# bit arguments
	# 0 : 1 - start, 0 - stop
	# 1 : 1 - rotate to beginning heading in calibration, 0 - just stop 
	# 2 : 1 - sleep after, 0 - don't sleep
	# 3 : 1 - keep control system on, 0 - turn it off after. Doesn't seem to be working
	# 4 : 0 - use default, 1-255 - max angle before recalib
	# 5 : 0 - use default, 1-255 - time spend in leveling mode
	# 6 : 0 - use default, 1-255 - milliseconds that Sphero has to stay leveled. If inter. starts again
	def selflevel(pid) do
		C.self_level(pid, 1,1,1,1,0,0,0)
	end
	
	def start() do
		{:ok, s} = C.start("/dev/tty.Sphero-YWY-AMP-SPP")
		randomroll(s,25)
		{:connection, s}
	end
	
	def start(device) do
		{:ok, s} = C.start(device)
		randomroll(s, 25)
		{:connection, s}
	end

	def randomroll(pid, delay) do
		# :erlang.round(:random.uniform*360)
		:lists.foreach(fn(x) ->
										 C.roll(pid, 10, x*10);
										 :timer.sleep(delay)
									 end, [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20])
	end

end
