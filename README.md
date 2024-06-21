# 运维管理工具

- Jumpserver
- Jenkins
- Zabbix
- EFK
- 证书申请系统

> 访问信息请查看私有表格

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

# Zabbix

## 连接信息

> 私

## 其他信息

> 所有模板、监控项都可在 `自建监控` 中查看

## 安装agent

```shell
# 下载安装脚本
wget https://raw.githubusercontent.com/623963982xxf/sk_xxf/master/zabbix/install_zabbix_agent.sh

# 执行初始化
bash install_zabbix_agent.sh 项目名+服务器类型 Agent类型

# 示例
bash install_zabbix_agent.sh test-nginx pasiv
```

# 阿里云

## 产品列表

- RDS云数据库
- Redis
- ECS
- 虚拟局域网-VPC
- 应用防火墙-WAF
- 域名

## 产品使用

### RDS

#### 管理

> 直接使用阿里云在线连接管理

#### 常用操作

> - 执行sql

### WAF

#### 管理

> 阿里云在线管理

#### 常用操作

> - 服务器白名单添加
>   - 打开WAF
>   - 进入 -> 防护对象
>   - 搜索对象，如：jenkins
>   - 查看防护规则
>   - 找到自定义规则
>   - 点击编辑
>   - 点击具体的规则右侧编辑
>   - 匹配内容 -> 添加IP
>
> - 新增防护对象
>   - 新增接入
>   - cname方式

### 安全组

> 非80,443端口的白名单添加，到对应的服务器安全组操作

# Jenkins

## 站点更新

> 选择带参数更新，根据开发需求，选择环境

## 其他

> p123视图下面包含常规的test环境流程
>
> 测试环境的服务器在jms，test分组下
