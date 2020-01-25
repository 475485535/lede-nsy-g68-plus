local m, s, o
local NXFS = require "nixio.fs"

m = Map("shadowsocksr", translate("IP black-and-white list"))

s = m:section(TypedSection, "access_control")
s.anonymous = true

-- Part of WAN
s:tab("wan_ac", translate("WAN IP AC"))

o = s:taboption("wan_ac", DynamicList, "wan_bp_ips", translate("WAN White List IP"))
o.datatype = "ip4addr"

o = s:taboption("wan_ac", DynamicList, "wan_fw_ips", translate("WAN Force Proxy IP"))
o.datatype = "ip4addr"

-- Part of LAN
s:tab("lan_ac", translate("LAN IP AC"))

o = s:taboption("lan_ac", ListValue, "lan_ac_mode", translate("LAN Proxy Mode"))
o:value("0","Bypassed Mode")
o:value("1","passed Mode")
o.default="0"

o = s:taboption("lan_ac", DynamicList, "lan_ac_ips", translate("LAN Bypassed Host List"))
o.datatype = "ipaddr"
luci.ip.neighbors({ family = 4 }, function(entry)
       if entry.reachable then
               o:value(entry.dest:string())
       end
end)
o:depends({lan_ac_mode="0"})
o.rmempty=true

o = s:taboption("lan_ac", DynamicList, "lan_ac_passed_ips", translate("LAN passed Host List"))
o.datatype = "ipaddr"
luci.ip.neighbors({ family = 4 }, function(entry)
       if entry.reachable then
               o:value(entry.dest:string())
       end
end)
o:depends({lan_ac_mode="1"})
o.rmempty=true

o = s:taboption("lan_ac", DynamicList, "lan_fp_ips", translate("LAN Force Proxy Host List"))
o.datatype = "ipaddr"
luci.ip.neighbors({ family = 4 }, function(entry)
       if entry.reachable then
               o:value(entry.dest:string())
       end
end)

o = s:taboption("lan_ac", DynamicList, "lan_gm_ips", translate("Game Mode Host List"))
o.datatype = "ipaddr"
luci.ip.neighbors({ family = 4 }, function(entry)
       if entry.reachable then
               o:value(entry.dest:string())
       end
end)

-- Part of MAC
s:tab("mac_ac", translate("MAC AC"))

o = s:taboption("mac_ac", ListValue, "mac_ac_mode", translate("MAC Proxy Mode"))
o:value("0","Bypassed Mode")
o:value("1","passed Mode")
o.default="0"

o = s:taboption("mac_ac", DynamicList, "mac_ac", translate("MAC Bypassed Host List"))
o.datatype = "macaddr"
luci.sys.net.mac_hints(function(x,d)
	if not luci.ip.new(d) then
		o:value(x,"%s (%s)"%{x,d})
	end

end)
o:depends({mac_ac_mode="0"})
o.rmempty=true

o = s:taboption("mac_ac", DynamicList, "mac_ac_passed", translate("MAC passed Host List"))
o.datatype = "macaddr"
luci.sys.net.mac_hints(function(x,d)
	if not luci.ip.new(d) then
		o:value(x,"%s (%s)"%{x,d})
	end

end)
o:depends({mac_ac_mode="1"})
o.rmempty=true

o = s:taboption("mac_ac", DynamicList, "mac_fp", translate("MAC Force Proxy Host List"))
o.datatype = "macaddr"
luci.sys.net.mac_hints(function(x,d)
	if not luci.ip.new(d) then
		o:value(x,"%s (%s)"%{x,d})
	end
end)

o = s:taboption("mac_ac", DynamicList, "mac_gm", translate("MAC Game Mode Host List"))
o.datatype = "macaddr"
luci.sys.net.mac_hints(function(x,d)
	if not luci.ip.new(d) then
		o:value(x,"%s (%s)"%{x,d})
	end

end)

-- Part of Self
-- s:tab("self_ac", translate("Router Self AC"))
-- o = s:taboption("self_ac",ListValue, "router_proxy", translate("Router Self Proxy"))
-- o:value("1", translatef("Normal Proxy"))
-- o:value("0", translatef("Bypassed Proxy"))
-- o:value("2", translatef("Forwarded Proxy"))
-- o.rmempty = false

s:tab("esc",  translate("Bypass Domain List"))

local escconf = "/etc/config/white.list"
o = s:taboption("esc", TextValue, "escconf")
o.rows = 13
o.wrap = "off"
o.rmempty = true
o.cfgvalue = function(self, section)
	return NXFS.readfile(escconf) or ""
end
o.write = function(self, section, value)
	NXFS.writefile(escconf, value:gsub("\r\n", "\n"))
end
o.remove = function(self, section, value)
	NXFS.writefile(escconf, "")
end


s:tab("block",  translate("Black Domain List"))

local blockconf = "/etc/config/black.list"
o = s:taboption("block", TextValue, "blockconf")
o.rows = 13
o.wrap = "off"
o.rmempty = true
o.cfgvalue = function(self, section)
	return NXFS.readfile(blockconf) or " "
end
o.write = function(self, section, value)
	NXFS.writefile(blockconf, value:gsub("\r\n", "\n"))
end
o.remove = function(self, section, value)
	NXFS.writefile(blockconf, "")
end

return m