#!/bin/bash
#
# 走公网ip通信，可选pub_pasiv，pub_active模式
# 走内网ip通信，可选pasiv，active
# 内网：install.sh srank active
# 外网：install.sh srank pasiv
# 外网：install.sh srank pub_active（主机名定义成公网ip地址的主动模式）

zab_conf_url='http://47.108.228.150/yangxilin/crust/raw/master/files/zabbix_agentd.conf'
zab_custom_shell_url='http://47.108.228.150/yangxilin/crust/raw/master'
owner=$1                  # 项目名称+服务器类型
mode=$2                   # 指定安装模式（pasiv被动，active主动，pub_active公网ip主动）

# 系统判断
get_OsType(){

  if [[ -f /etc/os-release ]]; then
    # 加载操作系统信息
    . /etc/os-release

    # 如果是ubuntu系统，初始化相关变量
    if [[ "$ID" == "ubuntu" ]]; then
        export os_installer="apt"
    elif [[ "$ID" == "centos" ]]; then
        export os_installer="yum"
    fi
  fi

}

# zabbix 安装
init_zab_agent(){

  # 获取安装类型
  mode=$1
  get_ipaddr(){
    # 取内网ip，适用情况：agent 和服务器在同一网段使用pasiv模式 + 不同网段使用active模式
    if [[ $mode == 'pasiv' || $mode == 'active' ]];then
      inner_ip=$(/sbin/ifconfig -a|grep inet|grep -vE '127.0.0.1|inet6|172'|awk '{print $2}'|tr -d "addr:")
    # 取公网ip，适用情况：agent 拥有公网ip，但是网段不统一，无法使用自动发现，需使用自动注册的情况下使用该参数，active模式
    elif [[ $mode == 'pub_active' || $mode == 'pub_pasiv' ]];then
      inner_ip=$(curl ifconfig.io 2> /dev/null)
    fi
  }
  # 安装依赖
  $os_installer install net-tools -y
  $os_installer install unzip -y
  $os_installer install dos2unix -y
  sleep 5
  # 安装zabbix
  $os_installer install zabbix-agent -y
  echo -e "\e[5;36m zabbix-agent安装成功 \e[0m"

  # 下载zabbix_agentd.conf
  cd /etc/zabbix && mv zabbix_agentd.conf zabbix_agentd.conf.old
  curl -sSLo /etc/zabbix/zabbix_agentd.conf "$zab_conf_url"

  # 拼接zabbix_agent_name
  get_ipaddr
  if [[ ! $owner ]];then
    zabbix_agent_name=$inner_ip
  else
    zabbix_agent_name=$owner-$inner_ip
  fi

  # 修改zabbix 主被动模式服务端配置
  if [[ $mode == 'pasiv' ]];then
    sed -i "s/0.0.0.0/$inner_ip/" /etc/zabbix/zabbix_agentd.conf
  elif [[ $mode == '*active*' ]];then
    sed -i "/=10.0.0.72/d" /etc/zabbix/zabbix_agentd.conf
  fi

  # 设置自动注册主机元数据
  case $owner in
  '*JAVA*')
    sed -i "s/srank/java/g" /etc/zabbix/zabbix_agentd.conf
    ;;
  '*Nginx*')
    sed -i "s/srank/nginx/g" /etc/zabbix/zabbix_agentd.conf
    ;;
  esac

  # 设置主机显示名称
  sed -i "s/Name+Ip/$zabbix_agent_name/" /etc/zabbix/zabbix_agentd.conf

  # 下载zabbix-custom-shell
  cd /etc/zabbix/ || exit && wget $zab_custom_shell_url/'zabbix/zab_monitor.sh'
  chmod +x /etc/zabbix/*.sh && chmod +x /etc/zabbix/*.py

  # 处理脚本和配置文件可能存在的特殊字符
  dos2unix /etc/zabbix/*.py && dos2unix /etc/zabbix/*.sh
  dos2unix /etc/zabbix/*.conf

  # 处理agent pid路径可能不一致的情况
  pid='PidFile='$(cat /lib/systemd/system/zabbix-agent.service | grep pid | awk -F'=' '{print $NF}')
  sed -i '/pid/d' /etc/zabbix/zabbix_agentd.conf
  sed -i "1 a $pid" /etc/zabbix/zabbix_agentd.conf

  # 授权zabbix 用户远程执行脚本权限（有需求才执行，也可修改为设置zabbix脚本目录的属组为zabbix，并指定755权限）
  chmod u+x /etc/sudoers
  sed -i '/zabbix/d' /etc/sudoers
  echo 'zabbix ALL=(ALL) NOPASSWD: ALL' >>/etc/sudoers
  chmod u-x /etc/sudoers
  chown zabbix.zabbix -R /etc/zabbix
  # usermod -aG docker zabbix || echo 'no docker group' 使用docker是执行
  service zabbix-agent restart && systemctl enable zabbix-agent
}
get_OsType
init_zab_agent $mode