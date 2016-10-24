function read_query(packet)
	if packet:byte() == proxy.COM_QUERY then
		-- print(os.date() .. " query: " .. packet:sub(2))
		proxy.queries:append(1, packet, {resultset_is_needed = false})
		return proxy.PROXY_SEND_QUERY
	end
end

function read_query_result(inj)
	print("[" .. os.date() .. "] " .. inj.query .. " [query-time=" .. (inj.query_time / 1000) .. "ms, " .. "response-time=" .. (inj.response_time / 1000) .. "ms]")
end