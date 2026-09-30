--!strict
-- A minimal signal that fires its listeners through the recycled thread.
-- Firing often (every frame, every hit...) no longer allocates a coroutine per listener.

local thread = require("../src")

type Listener<T...> = (T...) -> ()

local listeners: { Listener<string, number> } = {}

local function connect(listener: Listener<string, number>)
	table.insert(listeners, listener)
end

local function fire(name: string, damage: number)
	for _, listener in listeners do
		thread(listener, name, damage)
	end
end

connect(function(name, damage)
	print(`{name} took {damage} damage`)
end)

connect(
	function(name)
		task.wait(0.5) -- yielding is fine, this listener just gets its own thread
		print(`{name} can be hit again`)
	end
)

fire("Player1", 25)
