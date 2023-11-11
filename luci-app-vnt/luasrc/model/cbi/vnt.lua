local fs = require "luci.fs"
local http = luci.http
local nixio = require "nixio"

m = Map("vnt")
m.title = translate("VNT")
m.description = translate('vnt是一个简便高效的异地组网、内网穿透工具。项目地址：<a href="https://github.com/lbl8603/vnt">github.com/lbl8603/vnt</a>')

-- vnt-cli
m:section(SimpleSection).template  = "vnt/vnt_status"

s = m:section(TypedSection, "vnt-cli", translate("vnt-cli 客户端设置"))
s.anonymous = true

s:tab("general", translate("基本设置"))
s:tab("privacy", translate("高级设置"))
s:tab("infos", translate("连接信息"))
s:tab("upload", translate("上传程序"))

switch = s:taboption("general",Flag, "enabled", translate("Enable"))
switch.rmempty = false

token = s:taboption("general", Value, "token", translate("VPN名称"),
	translate("一个虚拟局域网的标识，连接同一服务器时，相同VPN名称的设备才会组成一个局域网"))
token.optional = false
token.placeholder = "abc123"

mode = s:taboption("general",ListValue, "mode", translate("接口模式"))
mode:value("dhcp")
mode:value("static")

ipaddr = s:taboption("general",Value, "ipaddr", translate("接口IP地址"),
	translate("每个vnt-cli客户端的接口IP不能相同"))
ipaddr.optional = false
ipaddr.datatype = "ip4addr"
ipaddr.placeholder = "10.26.0.5"
ipaddr:depends("mode", "static")

desvice_id = s:taboption("general",Value, "desvice_id", translate("设备ID"),
	translate("每台设备的唯一标识，注意不要重复，每个vnt-cli客户端的设备ID不能相同"))
desvice_id.placeholder = "5"

localadd = s:taboption("general",DynamicList, "localadd", translate("本地网段"),
	translate("每个vnt-cli客户端的内网lan网段不能相同，例如本机lanIP为192.168.1.1则填 192.168.1.0/24 "))
localadd.placeholder = "192.168.1.0/24"

peeradd = s:taboption("general",DynamicList, "peeradd", translate("对端网段"),
	translate("格式为对端的lanIP网段加英文，对端的接口IP，例如对端lanIP为192.168.2.1接口IP10.26.0.3则填192.168.2.0/24,10.26.0.3"))
peeradd.placeholder = "192.168.2.0/24,10.26.0.3"

forward = s:taboption("general",Flag, "forward", translate("启用IP转发"))
forward.rmempty = false

clibin = s:taboption("privacy", Value, "clibin", translate("vnt-cli程序路径"),
	translate("自定义vnt-cli的存放路径，确保填写完整的路径及名称,若指定的路径可用空间不足将会自动移至/tmp/vnt-cli"))
clibin.placeholder = "/tmp/vnt-cli"

vntshost = s:taboption("privacy", Value, "vntshost", translate("vnts服务器地址"),
	translate("相同的服务器，相同VPN名称的设备才会组成一个局域网"))
vntshost.placeholder = "域名:端口"

stunhost = s:taboption("privacy",DynamicList, "stunhost", translate("stun服务器地址"),
	translate("使用stun服务探测客户端NAT类型，不同类型有不同的打洞策略，可不填"))
stunhost.placeholder = "stun.qq.com:3478"

desvice_name = s:taboption("privacy", Value, "desvice_name", translate("设备名称"),
	translate("本机设备名称，方便区分不同设备"))
desvice_name.placeholder = "openwrt"

tunmode = s:taboption("privacy",ListValue, "tunmode", translate("TUN/TAP网卡"))
tunmode:value("tun")
tunmode:value("tap")

tcp = s:taboption("privacy",ListValue, "tcp", translate("TCP/UDP模式"),
	translate("有些网络提供商对UDP限制比较大，这个时候可以选择使用TCP模式，提高稳定性。一般来说udp延迟和消耗更低"))
tcp:value("udp")
tcp:value("tcp")

mtu = s:taboption("privacy",Value, "mtu", translate("MTU"),
	translate("设置虚拟网卡的mtu值，大多数情况下（留空）使用默认值效率会更高，也可根据实际情况进行微调，默认值：不加密1450，加密1410"))
mtu.datatype = "range(1,1500)"
mtu.placeholder = "1438"

par = s:taboption("privacy",Value, "par", translate("并行任务数"),
	translate("默认留空，任务并行度(必须为正整数),默认值为1,该值表示处理网卡读写的任务数,组网设备数较多、处理延迟较大时可适当调大此值"))
par.placeholder = "2"

punch = s:taboption("privacy",ListValue, "punch", translate("IPV4/IPV6"),
	translate("取值ipv4/ipv6，选择只使用ipv4打洞或者只使用ipv6打洞，默认两则都会使用,ipv6相对于ipv4速率会有所降低，ipv6更容易打通直连"))
punch:value("ipv4/ipv6")
punch:value("ipv4")
punch:value("ipv6")

passmode = s:taboption("privacy",ListValue, "passmode", translate("加密模式"),
	translate("默认off不加密，通常情况aes_gcm安全性高、aes_ecb性能更好，在低性能设备上aes_ecb速度最快"))
passmode:value("off")
passmode:value("aes_ecb")
passmode:value("sm4_cbc")
passmode:value("aes_cbc")
passmode:value("aes_gcm")

key = s:taboption("privacy",Value, "key", translate("加密密钥"),
	translate("先开启上方的加密模式再填写密钥才能生效，使用相同密钥的客户端才能通信，服务端无法解密(包括中继转发数据)"))
key.placeholder = "wodemima"

client_port = s:taboption("privacy", Value, "client_port", translate("本地监听端口"),
	translate("取值0~65535，指定本地监听的端口，留空默认随机端口"))
client_port.datatype = "port"

serverw = s:taboption("privacy",Flag, "serverw", translate("启用服务端客户端加密"),
	translate("用服务端通信的数据加密，采用rsa+aes256gcm加密客户端和服务端之间通信的数据，可以避免token泄漏、中间人攻击，上面的加密模式是客户端与客户端之间加密，这是服务器和客户端之间的加密，不是一个性质，无需选择加密模式"))
serverw.rmempty = false

finger = s:taboption("privacy",Flag, "finger", translate("启用数据指纹校验"),
	translate("开启数据指纹校验，可增加安全性，如果服务端开启指纹校验，则客户端也必须开启，开启会损耗一部分性能。注意：默认情况下服务端不会对中转的数据做校验，如果要对中转的数据做校验，则需要客户端、服务端都开启此参数"))
finger.rmempty = false

relay = s:taboption("privacy",Flag, "relay", translate("禁用P2P"),
	translate("在网络环境很差时，不使用p2p只使用服务器中继转发效果可能更好（可以配合tcp模式一起使用）"))
relay.rmempty = false

first_latency = s:taboption("privacy",Flag, "first_latency", translate("启用优化传输"),
	translate("启用后优先使用低延迟通道，默认情况下优先使用p2p通道，某些情况下可能p2p比客户端中继延迟更高，可启用此参数进行优化传输"))
first_latency.rmempty = false

multicast = s:taboption("privacy",Flag, "multicast", translate("启用模拟组播"),
	translate("模拟组播，高频使用组播通信时，可以尝试开启此参数，默认情况下会把组播当作广播发给所有节点。1.默认情况(组播当广播发送)：稳定性好，使用组播频率低时更省流量。2.模拟组播：高频使用组播时防止广播泛洪，客户端和中继服务器会维护组播成员等信息，注意使用此选项时，虚拟网内所有成员都需要开启此选项"))
multicast.rmempty = false

local process_status = luci.sys.exec("ps | grep vnt-cli | grep -v grep")
btn1 = s:taboption("infos", Button, "btn1")
btn1.inputtitle = translate("本机设备信息")
btn1.description = translate("点击上方按钮刷新，查看当前设备信息")
btn1.inputstyle = "apply"
btn1.write = function()
if process_status ~= "" then
    luci.sys.call("mkdir -p /root/.vnt-cli")
    luci.sys.call("[ $(cat /root/.vnt-cli/command-port) != $(netstat -anp | grep vnt-cli | grep 127.0.0.1 | awk -F ':' '{print $2}' | awk '{print $1}' | tr -d ' \n') ] && echo -n $(netstat -anp | grep vnt-cli | grep 127.0.0.1 | awk -F ':' '{print $2}' | awk '{print $1}' | tr -d ' \n') >/root/.vnt-cli/command-port")
    luci.sys.call("$(uci -q get vnt.@vnt-cli[0].clibin) --info >/tmp/vnt-cli_info")
else
    luci.sys.call("echo '错误：程序未运行！请启动程序后重新点击刷新' >/tmp/vnt-cli_info")
end
end

btn1info = s:taboption("infos", DummyValue, "btn1info")
btn1info.rawhtml = true
btn1info.cfgvalue = function(self, section)
    local content = nixio.fs.readfile("/tmp/vnt-cli_info") or ""
    return string.format("<pre>%s</pre>", luci.util.pcdata(content))
end


btn2 = s:taboption("infos", Button, "btn2")
btn2.inputtitle = translate("所有设备信息")
btn2.description = translate("点击上方按钮刷新，查看所有设备详细信息")
btn2.inputstyle = "apply"
btn2.write = function()
if process_status ~= "" then
    luci.sys.call("mkdir -p /root/.vnt-cli")  
    luci.sys.call("[ $(cat /root/.vnt-cli/command-port) != $(netstat -anp | grep vnt-cli | grep 127.0.0.1 | awk -F ':' '{print $2}' | awk '{print $1}' | tr -d ' \n') ] && echo -n $(netstat -anp | grep vnt-cli | grep 127.0.0.1 | awk -F ':' '{print $2}' | awk '{print $1}' | tr -d ' \n') >/root/.vnt-cli/command-port")
    luci.sys.call("$(uci -q get vnt.@vnt-cli[0].clibin) --all >/tmp/vnt-cli_all")
else
    luci.sys.call("echo '错误：程序未运行！请启动程序后重新点击刷新' >/tmp/vnt-cli_all")
end
end

btn2all = s:taboption("infos", DummyValue, "btn2all")
btn2all.rawhtml = true
btn2all.cfgvalue = function(self, section)
    local content = nixio.fs.readfile("/tmp/vnt-cli_all") or ""
    return string.format("<pre>%s</pre>", luci.util.pcdata(content))
end

btn3 = s:taboption("infos", Button, "btn3")
btn3.inputtitle = translate("所有设备列表")
btn3.description = translate("点击上方按钮刷新，查看所有设备列表")
btn3.inputstyle = "apply"
btn3.write = function()
if process_status ~= "" then
    luci.sys.call("mkdir -p /root/.vnt-cli")
    luci.sys.call("[ $(cat /root/.vnt-cli/command-port) != $(netstat -anp | grep vnt-cli | grep 127.0.0.1 | awk -F ':' '{print $2}' | awk '{print $1}' | tr -d ' \n') ] && echo -n $(netstat -anp | grep vnt-cli | grep 127.0.0.1 | awk -F ':' '{print $2}' | awk '{print $1}' | tr -d ' \n') >/root/.vnt-cli/command-port")
    luci.sys.call("$(uci -q get vnt.@vnt-cli[0].clibin) --list >/tmp/vnt-cli_list")
else
    luci.sys.call("echo '错误：程序未运行！请启动程序后重新点击刷新' >/tmp/vnt-cli_list")
end
end

btn3list = s:taboption("infos", DummyValue, "btn3list")
btn3list.rawhtml = true
btn3list.cfgvalue = function(self, section)
    local content = nixio.fs.readfile("/tmp/vnt-cli_list") or ""
    return string.format("<pre>%s</pre>", luci.util.pcdata(content))
end

btn4 = s:taboption("infos", Button, "btn4")
btn4.inputtitle = translate("路由转发信息")
btn4.description = translate("点击上方按钮刷新，查看本机路由转发路径")
btn4.inputstyle = "apply"
btn4.write = function()
if process_status ~= "" then
    luci.sys.call("mkdir -p /root/.vnt-cli")
    luci.sys.call("[ $(cat /root/.vnt-cli/command-port) != $(netstat -anp | grep vnt-cli | grep 127.0.0.1 | awk -F ':' '{print $2}' | awk '{print $1}' | tr -d ' \n') ] && echo -n $(netstat -anp | grep vnt-cli | grep 127.0.0.1 | awk -F ':' '{print $2}' | awk '{print $1}' | tr -d ' \n') >/root/.vnt-cli/command-port")
    luci.sys.call("$(uci -q get vnt.@vnt-cli[0].clibin) --route >/tmp/vnt-cli_route")
else
    luci.sys.call("echo '错误：程序未运行！请启动程序后重新点击刷新' >/tmp/vnt-cli_route")
end
end

btn4route = s:taboption("infos", DummyValue, "btn4route")
btn4route.rawhtml = true
btn4route.cfgvalue = function(self, section)
    local content = nixio.fs.readfile("/tmp/vnt-cli_route") or ""
    return string.format("<pre>%s</pre>", luci.util.pcdata(content))
end


local upload = s:taboption("upload", FileUpload, "upload_file")
upload.optional = true
upload.default = ""
upload.template = "vnt/other_upload"
upload.description = translate("可直接上传二进制程序vnt-cli和vnts或者以.tar.gz结尾的压缩包,可以上传新版本会自动覆盖旧版本")
local um = s:taboption("upload",DummyValue, "", nil)
um.template = "vnt/other_dvalue"

local dir, fd, chunk
dir = "/tmp/"
nixio.fs.mkdir(dir)
http.setfilehandler(
    function(meta, chunk, eof)
        if not fd then
            if not meta then return end

            if meta and chunk then fd = nixio.open(dir .. meta.file, "w") end

            if not fd then
                um.value = translate("错误：上传失败！")
                return
            end
        end
        if chunk and fd then
            fd:write(chunk)
        end
        if eof and fd then
            fd:close()
            fd = nil
            um.value = translate("文件已上传至") .. ' "/tmp/' .. meta.file .. '"'

            if string.sub(meta.file, -7) == ".tar.gz" then
                local file_path = dir .. meta.file
                os.execute("tar -xzf " .. file_path .. " -C " .. dir)
               if nixio.fs.access("/tmp/vnt-cli") then
                    um.value = um.value .. "\n" .. translate("程序/tmp/vnt-cli上传成功")
                end
               if nixio.fs.access("/tmp/vnts") then
                    um.value = um.value .. "\n" .. translate("程序/tmp/vnts上传成功")
                end
               end
                os.execute("chmod 777 /tmp/vnts")
                os.execute("chmod 777 /tmp/vnt-cli")                
        end
    end
)
if luci.http.formvalue("upload") then
    local f = luci.http.formvalue("ulfile")
end

-- vnts
s = m:section(TypedSection, "vnts", translate("vnts服务器设置"))
s.anonymous = true


switch = s:option(Flag, "enabled", translate("Enable"))
switch.rmempty = false

server_port = s:option(Value, "server_port", translate("本地监听端口"))
server_port.datatype = "port"
server_port.optional = false
server_port.placeholder = "2345"


white_Token = s:option(DynamicList, "white_Token", translate("VPN名称白名单"),
	translate("填写后将只能指定的VPN名称才能连接，留空则没有限制，所有VPN名称都可以连接此服务端"))
white_Token.placeholder = "abc123"

subnet = s:option(Value, "subnet", translate("指定DHCP网关"),
	translate("分配给vnt-cli客户端的接口IP网段"))
subnet.datatype = "ip4addr"
subnet.placeholder = "10.10.10.1"

servern_netmask = s:option(Value, "servern_netmask", translate("指定子网掩码"))
servern_netmask.placeholder = "225.225.225.0"

vntsbin = s:option(Value, "vntsbin", translate("vnts程序路径"),
	translate("自定义vnts的存放路径，确保填写完整的路径及名称,若指定的路径可用空间不足将会自动移至/tmp/vnts"))
vntsbin.placeholder = "/tmp/vnts"

logs = s:option(Flag, "logs", translate("启用日志"),
	translate("在vnts启动后会生成运行日志在/root/log目录里，最高会多达数M，默认不生成日志）"))
logs.rmempty = false

return m
