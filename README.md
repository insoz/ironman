# ironman

### nginx config
```nginx
server {
    listen 1081;
    add_header Cache-Control no-cache;

    access_log  logs/big-road.access.log access;
    error_log  logs/big-road.error.log;

    location / {
        default_type 'text/html';
        set $project 'big-road';
        access_by_lua_file conf/src/im-gateway.lua;
    }

    location @alpha {
        proxy_pass http://big-road-alpha;
        }

    location @beta {
        proxy_pass http://big-road-beta;
        }
}

upstream big-road-alpha {
    server 10.211.55.5:9093;
    upsync 10.211.55.3:2379/v2/keys/upstreams/big-road-alpha/ upsync_timeout=6m upsync_interval=500ms upsync_type=etcd strong_dependency=off;
    upsync_dump_path /opt/openresty/nginx/conf/services/big-road-alpha.conf;

    check interval=3000 rise=2 fall=5 timeout=1000 type=http;
    check_http_send "HEAD /v1/health/check HTTP/1.0\r\n\r\n";
    check_http_expect_alive http_2xx http_3xx;
}

upstream big-road-beta {
    server 10.211.55.6:9093;
    upsync 10.211.55.3:2379/v2/keys/upstreams/big-road-beta/ upsync_timeout=6m upsync_interval=500ms upsync_type=etcd strong_dependency=off;
    upsync_dump_path /opt/openresty/nginx/conf/services/big-road-beta.conf;

    check interval=3000 rise=2 fall=5 timeout=1000 type=http;
    check_http_send "HEAD /v1/health/check HTTP/1.0\r\n\r\n";
    check_http_expect_alive http_2xx http_3xx;
}
```
