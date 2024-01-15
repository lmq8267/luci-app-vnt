
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
	local command = io.popen("[ -f /tmp/vnt_time ] && start_time=$(cat /tmp/vnt_time) && time=$(($(date +%s)-start_time)) && day=$((time/86400)) && [ $day -eq 0 ] && day='' || day=${day}天 && time=$(date -u -d @${time} +'%H小时%M分%S秒') && echo $day $time")
	e.vntsta = command:read("*all")
	command:close()
        local command2 = io.popen('top -b -n1 | grep -E "$(pidof vnt-cli)" 2>/dev/null | grep -v grep | awk \'{for (i=1;i<=NF;i++) {if ($i ~ /vnt-cli/) break; else cpu=i}} END {print $cpu}\'')
	e.vntcpu = command2:read("*all")
	command2:close()
        local command3 = io.popen("cat /proc/$(pidof vnt-cli | awk '{print $NF}')/status | grep -w VmRSS | awk '{printf \"%.2f MB\", $2/1024}'")
	e.vntram = command3:read("*all")
	command3:close()
        local command4 = io.popen("[ -f /tmp/vnts_time ] && start_time=$(cat /tmp/vnts_time) && time=$(($(date +%s)-start_time)) && day=$((time/86400)) && [ $day -eq 0 ] && day='' || day=${day}天 && time=$(date -u -d @${time} +'%H小时%M分%S秒') && echo $day $time")
	e.vntsta2 = command4:read("*all")
	command4:close()
        local command5 = io.popen('top -b -n1 | grep -E "$(pidof vnts)" 2>/dev/null | grep -v grep | awk \'{for (i=1;i<=NF;i++) {if ($i ~ /vnts/) break; else cpu=i}} END {print $cpu}\'')
	e.vntscpu = command5:read("*all")
	command5:close()
        local command6 = io.popen("cat /proc/$(pidof vnts | awk '{print $NF}')/status | grep -w VmRSS | awk '{printf \"%.2f MB\", $2/1024}'")
	e.vntsram = command6:read("*all")
	command6:close()

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
