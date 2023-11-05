
local fs = require "nixio.fs"

m = Map("vnt")
m.title = translate("VNT")
m.description = translate('vnt是一个简便高效的异地组网、内网穿透工具。项目地址：<a href="https://github.com/lbl8603/vnt">github.com/lbl8603/vnt</a>')



-- vnt-cli
m:section(SimpleSection).template  = "vnt/vnt_status"

s = m:section(TypedSection, "vnt-cli", translate("vnt-cli 客户端设置"))
s.anonymous = true

s:tab("general", translate("基本设置"))
s:tab("privacy", translate("高级设置"))


switch = s:taboption("general",Flag, "enabled", translate("Enable"))
switch.rmempty = false


token = s:taboption("general", Value, "token", translate("VPN名称"),
	translate("一个虚拟局域网的标识，连接同一服务器时，相同VPN名称的设备才会组成一个局域网"))
token.optional = false


mode = s:taboption("general",ListValue, "mode", translate("接口模式"))
mode:value("dhcp")
mode:value("static")

ipaddr = s:taboption("general",Value, "ipaddr", translate("接口IP地址"),
	translate("每个vnt-cli客户端的接口IP不能相同"))
ipaddr.optional = false
ipaddr.datatype = "ip4addr"
ipaddr:depends("mode", "static")

desvice_id = s:taboption("general",Value, "desvice_id", translate("设备ID"),
	translate("每台设备的唯一标识，注意不要重复，每个vnt-cli客户端的设备ID不能相同"))


localadd = s:taboption("general",Value, "localadd", translate("本地网段"),
	translate("每个vnt-cli客户端的内网lan网段不能相同，本地多个网段使用:分隔，如  192.168.1.0/24:192.168.2.0/24  "))

peeradd = s:taboption("general",Value, "peeradd", translate("对端网段"),
	translate("对端多个网段使用:分隔，如  192.168.1.0/24,10.26.0.2:192.168.2.0/24,10.26.0.3"))

forward = s:taboption("general",Flag, "forward", translate("启用IP转发"))
forward.rmempty = false


vntshost = s:taboption("privacy", Value, "vntshost", translate("vnts服务器地址"),
	translate("相同的服务器，相同VPN名称的设备才会组成一个局域网"))

stunhost = s:taboption("privacy",Value, "stunhost", translate("stun服务器地址"),
	translate("使用stun服务探测客户端NAT类型，不同类型有不同的打洞策略，可不填"))
stunhost.datatype = "ipaddrport"

s:taboption("privacy", Value, "desvice_name", translate("设备名称"),
	translate("本机设备名称，方便区分不同设备"))

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

par = s:taboption("privacy",Value, "par", translate("并行任务数"),
	translate("默认留空，任务并行度(必须为正整数),默认值为1,该值表示处理网卡读写的任务数,组网设备数较多、处理延迟较大时可适当调大此值"))

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

-- vnts
s = m:section(TypedSection, "vnts", translate("vnts服务器设置"))
s.anonymous = true


switch = s:option(Flag, "enabled", translate("Enable"))
switch.rmempty = false

server_port = s:option(Value, "server_port", translate("本地监听端口"))
server_port.datatype = "port"
server_port.optional = false

white_Token = s:option(Value, "white_Token", translate("VPN名称白名单"),
	translate("填写后将只能指定的VPN名称才能连接，多个名称用:分隔，留空所有VPN名称都可以连接此服务端"))


subnet = s:option(Value, "subnet", translate("指定DHCP网关"),
	translate("分配给vnt-cli客户端的接口IP网段"))
subnet.datatype = "ip4addr"

servern_netmask = s:option(Value, "servern_netmask", translate("指定子网掩码"))


return m
