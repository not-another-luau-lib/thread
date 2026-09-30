--!strict
-- Runs callbacks through the recycled thread instead of `task.spawn`.

local thread = require("../src")

-- Arguments are forwarded to the callback, like `task.spawn`.
thread(print, "hello", "world")

-- Callbacks that don't yield all run on the same thread.
local first = thread(function()
end)

local second = thread(function()
end)

print(first == second) --> true

-- A callback that yields keeps its thread busy, so the next call gets a new one.
local busy = thread(function()
	task.wait(1)
	print("done waiting")
end)

local fresh = thread(function()
end)

print(busy == fresh) --> false
