local abtype = "pool"
local hosts = {
    ["10.211.55.3"] = "",
    ["10.211.55.6"] = ""
}

local function GetClientIP()
    local clientIP = ngx.var.remote_addr
    if clientIP == nil then
        clientIP = "unknown"
    end
    return clientIP
end

local function get_header_xenv()
    local args = ngx.req.get_headers()
    return args["__x_ferry_service"]
end

if get_header_xenv() == "alpha" then
    ngx.exec("@alpha")
end

local hostIP = GetClientIP()
if abtype == "pool" and hosts[hostIP] then -- 当abtype为pool并且判断来源IP为测试池中时, 返回到测试location
    ngx.exec("@alpha")
end

ngx.exec("@beta")