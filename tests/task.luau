--!strict
-- Minimal stand-in for Roblox's `task` library, since lest's native backend has none.

local function spawn(callback: thread | (...any) -> ...any, ...: any): thread
	local thread = if type(callback) == "thread" then callback else coroutine.create(callback)
	local ok, message = coroutine.resume(thread, ...)
	if not ok then
		error(message, 0)
	end
	return thread
end

return {
	spawn = spawn,
}
