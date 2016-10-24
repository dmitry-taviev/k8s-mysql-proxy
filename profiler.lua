function read_query(packet)
	if packet:byte() == proxy.COM_QUERY then
		print(os.date() .. " query: " .. packet:sub(2))
		-- proxy.queries:append(1, packet )
		-- return proxy.PROXY_SEND_QUERY
	end
end

-- function read_query_result(inj)
-- 	print("query-time: " .. (inj.query_time / 1000) .. "ms")
-- 	print("response-time: " .. (inj.response_time / 1000) .. "ms")
-- end