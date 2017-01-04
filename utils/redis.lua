local modulename = "redis"

local _M = { _VERSION = "0.0.1" }
local mt = { __index = _M }

local redis = require("resty.redis")

local redis_host = "10.211.55.3"
local redis_port = "6379"

_M.get_redis = function()
    local red = redis:new()
    red:set_timeout(1000)
    local ok, err = red:connect(redis_host, redis_port)

    if not ok then
        ngx.log(ngx.ERR, "链接redis服务器失败:", err)
        local errinfo = ERRORINFO.REDIS_CONNECT_ERROR
        local desc = "链接redis服务器失败"
        local response = doresp(errinfo, desc, err)
        ngx.say(response)
        ngx.exit(500)
    end
    return red
end

_M.close_redis = function(red)
    if not red then
        return
    end
    local pool_max_idle_time = 10000
    local pool_size = 100
    local ok, err = red:set_keepalive(pool_max_idle_time, pool_size)
    if not ok then
        ngx.log(ngx.ERR, "set keepalive error : ", err)
        local errinfo = ERRORINFO.REDIS_KEEPALIVE_ERROR
        local resp = "set keepalive error"
        local response = doresp(errinfo, resp, err)
        ngx.say(response)
        ngx.exit(500)
    end
end


return _M