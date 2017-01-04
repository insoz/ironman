local modulename = 'errinfo'
local _M = {}

_M._VERSION = '0.0.1'

_M.info = {
    --	index			    code    desc
    --	SUCCESS
    ["SUCCESS"]			        = { 20101,   'success '},

    --	System Level ERROR
    ['REDIS_ERROR']		        = { 40101, 'redis error for '},

    --	input or parameter error
    ['PARAMETER_NONE']		    = { 50101, 'expected parameter for '},
    ['PARAMETER_ERROR']		    = { 50102, 'parameter error for '},
    ['PARAMETER_NEEDED']	    = { 50103, 'need parameter for '},
    ['PARAMETER_TYPE_ERROR']	= { 50104, 'parameter type error for '},

    --  connect error
    ['REDIS_CONNECT_ERROR']	    = { 50301, 'redis connect error for '},
    ['REDIS_KEEPALIVE_ERROR']   = { 50302, 'redis keepalive error for '},
    ['ETCD_CONNECT_ERROR']      = { 50303, 'etcd connect error for '},

    ['ARG_BLANK_ERROR']	        = { 50405, 'no arg fetched from req '},
    ['ACTION_BLANK_ERROR']	    = { 50406, 'no action fetched from '},

    ['DOACTION_ERROR']	        = { 50501, 'error during action of '},

    --  unknown reason
    ['UNKNOWN_ERROR']		    = { 50601, 'unknown reason '},
}

return _M
