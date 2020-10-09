-- Configuration
STATS_FILE = "/tmp/nes.perf"
SAVESTATE_FILE = nil
--SAVESTATE_FILE = '/tmp/save.mst'
GATHER_DURATION = 0.5 * 1.6 * 1024 * 1024 -- Duration in number of CPU cycles

-- Actual truth that never change
JSR = 0x20
RTS = 0x60

-- Callback for performance aggregation
state = {
	last_instruction_addr = nil,
	last_instruction_cycle = nil,
	call_stack = {},
	next_stack_frame = nil,

	stats_file = nil,
	gather_cb_ref = nil,
}
REMOVE_STACK_FRAME = -1
function gather_perf_stats(address, value)
	-- Useful values
	local current_instruction_cycle = emu.getState().cpu.cycleCount

	-- Store last instruction information
	if state.last_instruction_addr ~= nil then
		local n_cycles = current_instruction_cycle - state.last_instruction_cycle

		-- Output stats
		if (state.stats_file ~= nil) then
			local str_stack = ''
			local i = 1
			while state.call_stack[i] ~= nil do
				str_stack = str_stack .. string.format("%04x", state.call_stack[i]) ..";"
				i = i + 1
			end
			state.stats_file:write(str_stack .. string.format("%04x", state.last_instruction_addr) .." ".. n_cycles .."\n")
		end
	end

	-- Remember info about this instruction (to be completed next call)
	state.last_instruction_addr = address
	state.last_instruction_cycle = current_instruction_cycle

	-- Update call stack
	if state.next_stack_frame ~= nil then
		if state.next_stack_frame == REMOVE_STACK_FRAME then
			table.remove(state.call_stack)
		else
			table.insert(state.call_stack, state.next_stack_frame)
		end
		state.next_stack_frame = nil
	end
	if value == JSR then
		state.next_stack_frame = emu.readWord(address + 1, emu.memType.cpu)
	elseif value == RTS then
		state.next_stack_frame = REMOVE_STACK_FRAME
	end

	-- Stop collecting after some time
	if (current_instruction_cycle >= state.time_end) then
		stop_gathering()
	end
end

function stop_gathering()
	emu.log("stop_gathering")
	emu.removeMemoryCallback(state.gather_cb_ref, emu.memCallbackType.cpuExec, 0, 0xffff)

	-- Close opened files
	if state.stats_file ~= nil then
		state.stats_file:close()
	end

	-- Stop emulator
	emu.stop(0)
end

-- Begin gathering
function start_gathering()
	-- Open flat stat files
	if STATS_FILE ~= nil then
		state.stats_file = io.open(STATS_FILE, 'w')
	end

	-- Register performance callback
	state.time_end = emu.getState().cpu.cycleCount + GATHER_DURATION
	emu.log(emu.getState().cpu.cycleCount .." -> ".. state.time_end)
	state.gather_cb_ref = emu.addMemoryCallback(gather_perf_stats, emu.memCallbackType.cpuExec, 0, 0xffff)
end

--
savestate_cb_handle = nil
function load_initial_savestate()
	local file = io.open(SAVESTATE_FILE, 'rb')
	local savestate = file:read('*all')
	file:close()
	emu.loadSavestate(savestate)
end
function init_from_savestate()
	emu.removeEventCallback(savestate_cb_handle, emu.eventType.startFrame)
	load_initial_savestate()
	start_gathering()
end

if SAVESTATE_FILE ~= nil then
	savestate_cb_handle = emu.addEventCallback(init_from_savestate, emu.eventType.startFrame)
else
	start_gathering()
end
