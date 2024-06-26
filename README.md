# 运维管理工具

- Jumpserver
- Jenkins
- Zabbix
- EFK
- 证书申请系统

> 访问信息请查看私有表格

# 产品介绍

## 架构

![image-20240626193344072](C:\Users\Windows\AppData\Roaming\Typora\typora-user-images\image-20240626193344072.png)

## 简介

### jms命名

> 基本规则：项目名+服务类型、服务名+服务类型
>
> 如：bb01-java，表示bb01项目，提供java服务的服务器
>
> ​    p4-java, 表示提供p4这个服务的java服务器

### 常规环境解释

#### test/demo/bb01:

- `test`：测试环境

- `demo`：demo环境

- `bb01`：公开环境

> **注：该三种环境为基础环境，类似入口，包含基类P1/P2服务，除该3个环境之外，其他环境均不含P1/P2**

#### 其他环境：

> 其他环境包含服务根据 JMS 命名判断

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

> 所有模板、监控项都可在 `模板组` -> `自建监控` 中查看

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
- 资源组

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

### 一些技巧

> - 带端口的域名未使用WAF，故添加白名单直接通过解析查找对应的服务器，进安全组添加

# Jenkins

## 站点更新

> 进入jks，找到项目，选择带参数更新，根据开发需求，选择环境

## 其他

> p123视图下面包含常规的test环境流程
>
> 测试环境的服务器在jms，test分组下

# ELK

## 自定义属性解释

> `lb_dealerCode`：环境类型（项目名称），如：test，demo，bb01等
>
> `lb_project`：后端服务名称，如：p1,p2,p4,p5,p6等

## 日志源

> 日志源均在 `/applications` 目录下寻找
>
> **日志源会被打包，请尽量使用ELK查找日志**

