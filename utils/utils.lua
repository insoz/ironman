local modulename = "utils"

local _M = { _VERSION = "0.0.1" }
local mt = { __index = _M }

local json = require('cjson.safe')
local redis = require('utils.redis')

local ERRORINFO = require('utils.errcode').info
local get_redis = redis.get_redis
local close_redis = redis.close_redis

local etcd_url = "http://10.211.55.3:2379/v2/keys/upstreams/"

local log_result = {}

_M.log_result = function(log, url)
    table.insert(log_result, log)
    return json.encode(log_result)
end

_M.doresp = function(info, desc, data)
    local response = {}

    local code = info[1]
    local err = info[2]
    response.code = code
    response.desc = desc and err .. desc or err
    if data then
        response.data = data
    end

    return json.encode(response)
end

local function register_etcd(method, url, log)
    local handle = io.popen("curl -s -S -X" .. method .. url)
    local result = handle:read("*a")
    handle:close()
    if not result or result == ngx.null or result == '' then
        ngx.log(ngx.ERR, "链接etcd失败: ", err)
        local errinfo = ERRORINFO.ETCD_CONNECT_ERROR
        local resp = "链接etcd失败"
        local response = _M.doresp(errinfo, resp, log_result)
        ngx.say(response)
        ngx.exit(500)
    end
    _M.log_result(log, url)
    return result
end

_M.post_data = function(body_info)
    local request_body = body_info
    local postData = json.decode(request_body)

    if not request_body then
        local errinfo = ERRORINFO.PARAMETER_NONE
        local desc = 'request_body or post data'
        local response = _M.doresp(errinfo, desc)
        log:errlog(desc)
        ngx.say(response)
        ngx.exit(500)
    end

    if not postData then
        local errinfo = ERRORINFO.PARAMETER_ERROR
        local desc = '数据不是json格式'
        local response = _M.doresp(errinfo, desc)
        ngx.say(response)
        ngx.exit(500)
    end
    return postData
end

_M.get_redis_project = function(project_name)
    local red = get_redis()
    if not project_name then
        return
    end

    local project_info, err = red:get(project_name)
    if not project_info or project_info == ngx.null then
        ngx.log(ngx.ERR, "从redis获取值失败: ", err)
        local errinfo = ERRORINFO.REDIS_ERROR
        local resp = "从redis获取值失败"
        local response = _M.doresp(errinfo, resp, err)
        ngx.say(response)
        ngx.exit(500)
    end

    local ip_info = json.decode(project_info)
    return ip_info
end



_M.reg_etcd = function(project, project_info)
    local alpha_url = etcd_url .. project .. "-alpha/"
    local beta_url = etcd_url .. project .. "-beta/"

    if project_info.alpha then
        for _k, alpha_ip in pairs(project_info.alpha) do
            register_etcd("PUT ", alpha_url .. alpha_ip, "注册" .. alpha_ip .. "到alpha服务", project)
            register_etcd("DELETE ", beta_url .. alpha_ip, "删除" .. alpha_ip .. "从beta服务", project)
        end
    end
    if project_info.beta then
        for _k, beta_ip in pairs(project_info.beta) do
            register_etcd("PUT ", beta_url .. beta_ip, "注册" .. beta_ip .. "到beta服务", project)
            register_etcd("DELETE ", alpha_url .. beta_ip, "删除" .. beta_ip .. "从alpha服务", project)
        end
    end
end

_M.unreg_etcd = function(project, project_info)
    local alpha_url = etcd_url .. project .. "-alpha/"
    local beta_url = etcd_url .. project .. "-beta/"

    if project_info.alpha then
        for _k, alpha_ip in pairs(project_info.alpha) do
            register_etcd("PUT ", beta_url .. alpha_ip, "注册" .. alpha_ip .. "到beta服务", project)
            register_etcd("DELETE ", alpha_url .. alpha_ip, "删除" .. alpha_ip .. "从alpha服务", project)
        end
    end
    if project_info.beta then
        for _k, beta_ip in pairs(project_info.beta) do
            register_etcd("DELETE ", alpha_url .. beta_ip, "删除" .. beta_ip .. "从alpha服务", project)
            register_etcd("PUT ", beta_url .. beta_ip, "注册" .. beta_ip .. "到beta服务", project)
        end
    end
end

return _M