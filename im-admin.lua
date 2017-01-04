local utils = require('utils.utils')
local ERRORINFO = require('utils.errcode').info

local postdata = utils.post_data
local register = utils.reg_etcd
local unregister = utils.unreg_etcd
local get_redis_project = utils.get_redis_project
local doresp = utils.doresp

local status = ngx.shared.status

local body_info = ngx.var.request_body

local function get_args(arg)
    local args = ngx.req.get_uri_args()
    return args[arg]
end

local action = get_args("action")

local function get_param(project)
    local project_status = status:get("project")
    if project_status then
        ngx.log(ngx.ERR, project_status)
        return project_status
    end

    local errinfo = ERRORINFO.DOACTION_ERROR
    local resp = project .. " 不存在或已删除"
    local response = doresp(errinfo, resp)
    ngx.say(response)
    ngx.exit(200)
end

local function set_param(project)
    local project_shard = status:get("project")
    if not project_shard then
        local resp = project .. " 添加测试失败."
        local errinfo = ERRORINFO.UNKNOWN_ERROR
        local response = doresp(errinfo, resp)
        ngx.say(response)
        ngx.exit(500)
    end
end

local function del_param(project)
    local project_shard = status:get("project")
    if project_shard then
        status:delete(project)
    end
end

projects = postdata(body_info)

if action == "set" then
    for _k, v in pairs(projects) do
        set_param(v)
        local project_info = get_redis_project(v)
        register(v, project_info)
    end
    local reg_result = utils.log_result()
    local errinfo = ERRORINFO.SUCCESS
    local resp = "调用etcd注册接口成功."
    local response = doresp(errinfo, resp, reg_result)
    ngx.say(response)
    ngx.exit(200)
elseif action == "del" then
    for _k, v in pairs(projects) do
        del_param(v)
        local project_info = get_redis_project(v)
        unregister(v, project_info)
    end
    local reg_result = utils.log_result()
    local errinfo = ERRORINFO.SUCCESS
    local resp = "调用etcd注册接口成功."
    local response = doresp(errinfo, resp, reg_result)
    ngx.say(response)
    ngx.exit(200)
elseif action == "check" then
    for _k, v in pairs(projects) do
        local status_name = get_param(v)
        local errinfo = ERRORINFO.DOACTION_ERROR
        local resp = "当前测试项目为:" .. status_name
        local response = doresp(errinfo, resp)
        ngx.say(response)
        ngx.exit(200)
    end
else
    local errinfo = ERRORINFO.DOACTION_ERROR
    local resp = "无效参数."
    local response = doresp(errinfo, resp)
    ngx.say(response)
    ngx.exit(400)
end