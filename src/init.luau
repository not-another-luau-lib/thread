--!native
--!optimize 2

--[=[
	@class Thread
	
	Runs callbacks on a recycled thread instead of creating a new one per call.

	`task.spawn(callback)` allocates a coroutine every time. This module keeps one
	idle thread around and hands callbacks to it; a new thread is only created when
	the idle one is busy because a previous callback yielded.

	```lua
	local thread = require(path.to.Thread)
	thread(print, "hello", "world")
	```
]=]

export type Spawn = <T...>(callback: (T...) -> (), T...) -> thread
local freeThread: thread? = nil

const function passer(callback, ...)
	const acquired = freeThread
	freeThread = nil
	callback(...)

	if not freeThread then
		freeThread = acquired
	end
end

const function yielder()
	passer(coroutine.yield())

	while freeThread == coroutine.running() do
		passer(coroutine.yield())
	end
end

--[=[
	@within Thread
	@type Spawn <T...>(callback: (T...) -> (), T...) -> thread

	The module itself: requiring `Thread` returns this function directly, there is
	no `Thread.spawn`.

	Runs `callback(...)` immediately on the idle thread, creating one if none is
	free, and returns the thread `callback` ran on.

	If `callback` yields, the thread it ran on stays busy until it finishes, and
	the next call gets a fresh thread. Once a callback returns without yielding, its
	thread becomes the idle one again.

	```lua
	local thread = require(path.to.Thread)

	thread(function(name)
		task.wait(1)
		print(`hello {name}`)
	end, "world")
	```
]=]
return function<T...>(callback: (T...) -> (), ...: T...): thread
	freeThread = freeThread or task.spawn(yielder)
	return task.spawn(freeThread :: thread, callback, ...)
end
