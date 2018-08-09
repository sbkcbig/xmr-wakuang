#!/bin/bash
#!/usr/bin/expect -f
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

#=================================================
#	System Required: CentOS 6+/Debian 6+/Ubuntu 14.04+/others(test)
#	Description: Auto-install the ServerStatus Client
#	Version: 1.1
#	Author: dovela
#=================================================

file="/home/xmrstak"
xmr_folder="${file}/bin"
xmr_conf="${xmr_folder}/config.txt"
xmr_cpu="${xmr_folder}/cpu.txt"
xmr_pools="${xmr_folder}/pools.txt"
sepa='———————————-'

check_sys(){
	 if [[ -f /etc/redhat-release ]]; then
		release="centos"
	 elif cat /etc/issue | grep -q -E -i "debian"; then
		release="debian"
	 elif cat /etc/issue | grep -q -E -i "ubuntu"; then
		release="ubuntu"
	 elif cat /etc/issue | grep -q -E -i "centos|red hat|redhat"; then
		release="centos"
	 elif cat /proc/version | grep -q -E -i "debian"; then
		release="debian"
	 elif cat /proc/version | grep -q -E -i "ubuntu"; then
		release="ubuntu"
	 elif cat /proc/version | grep -q -E -i "centos|red hat|redhat"; then
		release="centos"
         fi
	bit=`uname -m`
}

check_PID(){
    PID=`ps -ef | grep -v grep | grep xmr-stak | awk '{print $2}'`
}

set_http_port(){
    while true
    do
    stty erase '^H' && read -p " 矿机网页监视端口 Http_port, 0为不监控, 默认10567 (0-65535):" x_port
    [[ -z ${x_port} ]] && x_port=10567
    expr ${x_port} + 0 &>/dev/null
    if [[ $? == 0 ]]; then
        if [[ ${x_port} -ge 0 ]] && [[ ${x_port} -le 65535 ]]; then
            break
        else
            echo ' Error, 请输入正确的端口号 (0-65535) !'
        fi
    else
        echo ' Error, 请输入正确的端口号 (0-65535) !'
    fi
    done
}

set_pool_address(){
    echo -e "
  1.pool.supportxmr.com:3333
  2.xmr-us-east1.nanopool.org:14444
  3.xmr-us-west1.nanopool.org:14444
  4.xmr-eu1.nanopool.org:14444
${sepa}
  或手动输入地址 by manual
  "
  echo && stty erase '^H' && read -p " 矿池地址 Pool_address (默认 pool.supportxmr.com:3333 ):" x_address_num
    case ${x_address_num} in
        1)
        x_address=pool.supportxmr.com:3333
        ;;
        2)
        x_address=xmr-us-east1.nanopool.org:14444
        ;;
        3)
        x_address=xmr-us-west1.nanopool.org:14444
        ;;
        4)
        x_address=xmr-eu1.nanopool.org:14444
        ;;
        *)
        if [[ -z ${x_address_num} ]]; then
            x_address=pool.supportxmr.com:3333
        else
        x_address=${x_address_num}
        fi
        ;;
    esac
}

set_xmr(){
    set_http_port
    set_pool_address
    stty erase '^H' && read -p " 数字币名称 Currency (默认 monero7 ):" x_currency
    [[ -z ${x_currency} ]] && x_currency=monero7
    stty erase '^H' && read -p " 钱包地址 Username (例: 49EJKgLMGCSFTEx5R7MTUPdhCrY8CjCiPMgLfRWcjh7eYf92f4FQ9PyCKDfBKNJ2EASBF9GB3yYeBKnVm4rGXhwG8ahAWdS ):" x_username
    [[ -z ${x_username} ]] && echo " Error, 钱包地址未输入!" && exit 1
    stty erase '^H' && read -p " 矿池密码 Password (例: do1:10000@qq.com ):" x_passwd
    stty erase '^H' && read -p " 矿机名称 Rig_ID (例: do1 ):" x_id
    stty erase '^H' && read -p " 矿池是否需要 TLS/SSL, 默认n (y/n):" x_tls
    [[ -z ${x_tls} ]] && x_tls=n
 #   stty erase '^H' && read -p " 是否开启 Nicehash, 默认n (y/n):" x_nicehash
 #   [[ -z ${x_nicehash} ]] && x_nicehash=n
    x_nicehash=n
 #   stty erase '^H' && read -p " 是否开启 Multiple pools, 默认n (y/n):" x_multiple
 #   [[ -z ${x_multiple} ]] && x_multiple=n
    x_multiple=n
    x_text=" browser interface port: "${x_port}"\n Currency: "${x_currency}"\n Pool address: "${x_address}"\n Username: "${x_username}"\n Password: "${x_passwd}"\n Rig ID: "${x_id}"\n TLS/SSL: "${x_tls}"\n Nicehash: "${x_nicehash}"\n Multiple pools: "${x_multiple}
    clear
    echo -e "${sepa}\n${x_text}\n${sepa}"
    read -p " 确认无误后按 Enter 执行, 否则 Ctrl^c 取消" dovela
}

Reset_xmr(){    
    set_xmr
    cd ${xmr_folder}
    rm -rf ${xmr_conf} ${xmr_cpu} ${xmr_pools}
    nohup ./xmr-stak -i ${x_port} -o ${x_address} -u ${x_username} -r ${x_id} -p ${x_passwd} --currency ${x_currency} &>/dev/null &
    echo ' 重新配置完毕, xmr-stak 已启动...'
}

View_conf(){
    xmr_port=`cat ${xmr_conf} | grep httpd_port | awk '{print $3}' | tail -n 1 | sed 's/,/ /g'`
    xmr_text=`cat ${xmr_pools} | grep pool_address | tail -n 1 | sed -e 's/"/ /g;s/,/ /g'
    xmr_address=`echo ${xmr_text} | awk '{print $4}'`
    xmr_username=`echo ${xmr_text} | awk '{print $7}'`
    xmr_passwd=`echo ${xmr_text} | awk '{print $13}'`
    xmr_id=`echo ${xmr_text} | awk '{print $10}'`
    xmr_tls=`echo ${xmr_text} | awk '{print $19}'`
    xmr_nicehash=`echo ${xmr_text} | awk '{print $16}'`
    xmr_currency=`cat ${xmr_pools} | grep currency | sed 's/"/ /g' | awk '{print $3}'
    xmr_text=' browser interface port: '${xmr_port}\n' Currency: '${xmr_currency}\n' Pool address: '${xmr_address}\n' Username: '${xmr_username}\n' Password: '${xmr_passwd}\n' Rig ID: '${xmr_id}\n' TLS/SSL: '${xmr_tls}\n' Nicehash: '${xmr_nicehash}
    clear
    echo -e "${sepa}\n${xmr_text}\n${sepa}"
}

centos_yum(){
	yum install -y epel-release && yum clean all && yum update
	yum install -y git wget libmicrohttpd-dev libssl-dev cmake build-essential libhwloc-dev wget cpulimit
}

debian_apt(){
    apt-get update
    apt-get upgrade -y
    apt install -y libmicrohttpd-dev libssl-dev cmake build-essential libhwloc-dev git wget cpulimit
}

install_env(){
    check_sys
    if [[ ${release} == "centos" ]]; then
		centos_yum
	  else
		debian_apt
	fi
    echo ' 依赖环境安装完成!'
}

Install_xmr(){
    if [[ -e ${file} ]]; then
        echo -e " Error, 文件已存在于 ${file}, 请先查看或卸载 !" && exit 1
    else
        echo
    fi
    set_xmr
    clear
    install_env
    clear
    mkdir ${file}
    git clone https://github.com/dovela/xmr-stak.git ${file}
    cd ${file} && rm -rf OneClickMine.sh
    cmake ./ -DCUDA_ENABLE=OFF -DOpenCL_ENABLE=OFF && make install
    sysctl -w vm.nr_hugepages=128
    echo -e "soft memlock 262144\nhard memlock 262144" >> /etc/security/limits.conf
    cd ${xmr_folder}
    nohup ./xmr-stak -i ${x_port} -o ${x_address} -u ${x_username} -r ${x_id} -p ${x_passwd} --currency ${x_currency} &>/dev/null &
    echo ' 配置完毕, xmr-stak 已启动...'
    Limit_xmr
}
    
Run_xmr(){
    check_PID
    [[ -n ${PID} ]] && echo ' Error, xmr-stak 正在运行 !' && exit 1
    cd ${xmr_folder}
    nohup ./xmr-stak &> /dev/null &
    check_PID
    [[ -n ${PID} ]] && echo ' xmr-stak 已启动 !'
    Limit_xmr
}

Stop_xmr(){
    check_PID
    [[ -z ${PID} ]] && echo ' Error, xmr-stak 未运行 !' && exit 1
    kill -9 ${PID}
    check_PID
    [[ -z ${PID} ]] && echo ' xmr-stak 已停止 !'
}

Remove_xmr(){
    check_PID
    [[ -n ${PID} ]] && kill -9 ${PID}
    rm -rf ${file}
}

Limit_xmr(){
    cpu_core=`cat /proc/cpuinfo | grep "processor"| wc -l`
    cpu_percentage_total=`expr ${cpu_core} \* 100`
    check_PID
    if [[ -n ${PID} ]]; then
        echo ' 限制 xmr-stak 占用cpu总百分比 (逻辑cpu数 * 100), 默认不限制'
        stty erase '^H' && read -p " 请输入[1-${cpu_percentage_total}]间的整数 (例: 50): " x_limit
        [[ -z ${x_limit} ]] && echo ' 不限制 xmr-stak cpu占用率' && exit 1
        expr ${x_limit} + 0 &>/dev/null
        if [[ $? == 0 ]]; then
            if [[ ${x_limit} -ge 1 ]] && [[ ${x_limit} -le ${cpu_percentage_total} ]]; then
            nohup cpulimit -p ${PID} -l ${x_limit} &>/dev/null &
            else
                echo ' Error, 请输入正确的整数!'
            fi
        else
            echo ' Error, 请输入正确的整数!'
        fi
    else
        echo ' Error, xmr-stak 未在运行! 请运行后再执行此项'
    fi
}

clear
check_sys
[ $(id -u) != "0" ] && echo -e "Error: You must be root to run this script" && exit 1
echo -e " 出现问题请在 https://github.com/dovela/xmr-stak 处提issue
${sepa}
  1.安装并启动 xmr-stak
  2.运行 xmr-stak  
  3.停止运行 xmr-stak
  4.卸载 xmr-stak
${sepa}
  5.查看当前配置
  6.重新配置
  7.限制 xmr-stak cpu占用率
${sepa}
  输入数字开始，或ctrl + c退出
"
echo && stty erase '^H' && read -p " 请输入数字[1-7]:" num
 case "$num" in
    1)
    Install_xmr
    ;;
    2)
    Run_xmr
    ;;
    3)
    Stop_xmr
    ;;
    4)
    Remove_xmr
    ;;
    5)
    View_conf
    ;;
    6)
    Reset_xmr
    ;;
    7)
    Limit_xmr
    ;;
    *)
    echo -e "Error, 请输入正确的数字 [1-7]!"
	;;
esac
