
module("luci.controller.vnt", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/vnt") then
		return
	end
                  
        entry({"admin", "vpn", "vnt"}, alias("admin", "vpn", "vnt", "vnt"),_("VNT"), 44).dependent = true
	entry({"admin", "vpn", "vnt", "vnt"}, cbi("vnt"),_("VNT"), 45).leaf = true
	entry({"admin", "vpn",  "vnt",  "log"}, form("log"),_("客户端日志"), 46).leaf = true
	entry({"admin", "vpn", "vnt", "get_log"}, call("get_log")).leaf = true
	entry({"admin", "vpn", "vnt", "clear_log"}, call("clear_log")).leaf = true
	entry({"admin", "vpn", "vnt", "log2"}, form("log2"),_("服务端日志"), 47).leaf = true
	entry({"admin", "vpn", "vnt", "get_log2"}, call("get_log2")).leaf = true
	entry({"admin", "vpn", "vnt", "clear_log2"}, call("clear_log2")).leaf = true
	entry({"admin", "vpn", "vnt", "status"}, call("act_status")).leaf = true
end

function act_status()
	local e = {}
	e.crunning = luci.sys.call("pgrep vnt-cli >/dev/null") == 0
	e.srunning = luci.sys.call("pgrep vnts >/dev/null") == 0
	luci.http.prepare_content("application/json")
	luci.http.write_json(e)
end

function get_log()
    local log = ""
    local files = {"/log/vnt-cli.log", "/log/vnt-cli.1.log", "/log/vnt-cli.2.log", "/log/vnt-cli.3.log", "/log/vnt-cli.4.log", "/log/vnt-cli.5.log"}
    for i, file in ipairs(files) do
        if luci.sys.call("[ -f '" .. file .. "' ]") == 0 then
            log = log .. luci.sys.exec("cat " .. file)
        end
    end
    luci.http.write(log)
end

function clear_log()
	luci.sys.call("rm -rf /log/vnt-cli*.log")
end

function get_log2()
	local log2 = ""
    local files = {"/log/vnts.log", "/log/vnts.1.log", "/log/vnts.2.log", "/log/vnts.3.log", "/log/vnts.4.log", "/log/vnts.5.log"}
    for i, file in ipairs(files) do
        if luci.sys.call("[ -f '" .. file .. "' ]") == 0 then
            log2 = log2 .. luci.sys.exec("cat " .. file)
        end
    end
    luci.http.write(log2)
end

function clear_log2()
	luci.sys.call("rm -rf /log/vnts*.log")
end
