# Supervisord

## 安装

```shell
   sudo yum install epel-release
   sudo yum install supervisor
```

## 创建自有服务

> 需要创建srk用户
>
> ```shell
> useradd -m srk
> echo "srk:123456Aa" | chpasswd
> ```

```shell
cat >> /etc/supervisord.d/myapp.ini <EOF
[program:myapp]
command=/usr/bin/java -jar /home/srk/helloworld.jar		# 注意文件权限
autostart=true
autorestart=true
stderr_logfile=/var/log/myapp.err.log
stdout_logfile=/var/log/myapp.out.log
user=srk
EOF
```

## 启动Supervisord服务

`systemctl start supervisord`

## 管理自建服务

```shell
# 更新服务配置
supervisorctl reread
supervisorctl update

# 管理服务
supervisorctl start myapp
supervisorctl stop myapp
supervisorctl status myapp

# 验证
ps -elf | grep srk
```

