--!strict
local Lest = require("@lest")
local describe, it, expect = Lest.describe, Lest.it, Lest.expect

if not (_G :: any).task then
	(_G :: any).task = require("./task")
end

local spawn = require("../src")

describe("Thread", function()
	it("runs the callback immediately with its arguments", function()
		local received: { any } = {}
		spawn(function(a: number, b: string)
			received = { a, b }
		end, 1, "two")

		expect(received).toEqual({ 1, "two" })
	end)

	it("reuses the same thread when callbacks do not yield", function()
		local first: thread?, second: thread?
		spawn(function()
			first = coroutine.running()
		end)
		spawn(function()
			second = coroutine.running()
		end)

		expect(first).toBe(second)
	end)

	it("returns the thread the callback ran on", function()
		local running: thread?
		local thread = spawn(function()
			running = coroutine.running()
		end)

		expect(thread).toBe(running)
	end)

	it("uses a new thread while the previous callback is yielded", function()
		local yielded: thread
		spawn(function()
			yielded = coroutine.running()
			coroutine.yield()
		end)

		local other: thread?
		spawn(function()
			other = coroutine.running()
		end)

		expect(other).toNotBe(yielded)
	end)

	it("recycles a thread once its yielded callback finishes", function()
		local yielded: thread
		spawn(function()
			yielded = coroutine.running()
			coroutine.yield()
		end)
		task.spawn(yielded)

		local after: thread?
		spawn(function()
			after = coroutine.running()
		end)

		expect(after).toBe(yielded)
	end)
end)

return nil
