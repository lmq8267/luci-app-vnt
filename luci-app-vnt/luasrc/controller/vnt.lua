-- vnt Luci configuration page. Made by 981213

module("luci.controller.vnt", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/vnt") then
		return
	end

	entry({"admin", "vpn"}, firstchild(), "VPN", 45).dependent = false
	entry({"admin", "vpn", "vnt"}, cbi("vnt"), _("VNT"), 45).dependent = true
	entry({"admin", "vpn", "vnt", "status"}, call("act_status")).leaf = true
end

function act_status()
	local e = {}
	e.crunning = luci.sys.call("pgrep vnt-cli >/dev/null") == 0
	e.srunning = luci.sys.call("pgrep vnts >/dev/null") == 0
	luci.http.prepare_content("application/json")
	luci.http.write_json(e)
end
