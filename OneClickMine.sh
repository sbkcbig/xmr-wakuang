#!/bin/bash
#!/usr/bin/expect
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

#=================================================
#	System Required: CentOS 6+/Debian 6+/Ubuntu 14.04+/others(test)
#	Description: Auto-install the ServerStatus Client
#	Version: 0.2
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

Install_Tcl(){
    cd /tmp && wget https://prdownloads.sourceforge.net/tcl/tcl8.4.20-src.tar.gz && tar -zxvf tcl8.4.20-src.tar.gz
    cd tcl8.4.20/unix
    ./configure
    make && make install
}

Install_expect(){
    cd /tmp && wget https://jaist.dl.sourceforge.net/project/expect/Expect/5.45.4/expect5.45.4.tar.gz && tar -zxvf expect5.45.4.tar.gz
    cd expect5.45.4
    ./configure
    make && make install
    ln -s /usr/local/bin/expect /usr/bin/expect
}

Set_xmr(){
    stty erase '^H' && read -p " 矿机网页监视端口 Browser_interface_port, 默认10567 (22-65535):" x_port
    [[ -z ${x_port} ]] && x_port=10567
    stty erase '^H' && read -p " 数字币名称 Currency (默认 monero7 ):" x_currency
    [[ -z ${x_currency} ]] && x_currency=monero7
    stty erase '^H' && read -p " 矿池地址 Pool_address (默认 pool.supportxmr.com:3333 ):" x_address
    [[ -z ${x_address} ]] && x_address=pool.supportxmr.com:3333
    stty erase '^H' && read -p " 钱包地址 Username (例: 49EJKgLMGCSFTEx5R7MTUPdhCrY8CjCiPMgLfRWcjh7eYf92f4FQ9PyCKDfBKNJ2EASBF9GB3yYeBKnVm4rGXhwG8ahAWdS ):" x_username
    [[ -z ${x_username} ]] && echo " Error, 钱包地址未输入!" && exit 1
    stty erase '^H' && read -p " 矿池密码 Password (例: do1:10000@qq.com ):" x_passwd
    stty erase '^H' && read -p " 矿机名称 Rig_ID (例: do1 ):" x_id
    stty erase '^H' && read -p " 矿池是否需要 TLS/SSL, 默认n (y/n):" x_tls
    [[ -z ${x_tls} ]] && x_tls=n
    stty erase '^H' && read -p " 是否开启 Nicehash, 默认n (y/n):" x_nicehash
    [[ -z ${x_nicehash} ]] && x_nicehash=n
    stty erase '^H' && read -p " 是否开启 Multiple pools, 默认n (y/n):" x_multiple
    [[ -z ${x_multiple} ]] && x_multiple=n
    x_text=" browser interface port: "${x_port}"\n Currency: "${x_currency}"\n Pool address: "${x_address}"\n Username: "${x_username}"\n Password: "${x_passwd}"\n Rig ID: "${x_id}"\n TLS/SSL: "${x_tls}"\n Nicehash: "${x_nicehash}"\n Multiple pools: "${x_multiple}
    clear
    echo -e "${sepa}\n${x_text}\n${sepa}"
    read -p "\n 确认无误后按 Enter 执行, 否则 Ctrl^c 取消" dovela
}

VIew_conf(){
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
    yum install -y expect git wget libmicrohttpd-dev libssl-dev cmake build-essential libhwloc-dev screen wget
}

debian_apt(){
    apt-get update
    apt-get upgrade -y
    apt install -y libmicrohttpd-dev libssl-dev cmake build-essential libhwloc-dev git screen wget
    Install_Tcl
    Install_expect
}

Install_env(){
    check_sys
    if [[ ${release} == "centos" ]]; then
		centos_yum
	  else
		debian_apt
	fi
    echo ' 依赖环境安装完成, 请再次运行脚本'
}

screen_env_deploy(){
    xmr_check=`screen -ls | grep xmr | awk '{print $1}' | head -n 1`
    if [[ -n "${xmr_check}" ]]; then
        screen -r ${xmr_check}
        check_PID
        [[ -n ${PID} ]] && echo ' xmr-stak 正在运行 !' && exit 1
    else
        screen -S xmr
    fi
}

Install_xmr(){
    clear
    Set_xmr
    clear
    screen_env_deploy
    mkdir ${file}
    git clone https://github.com/dovela/xmr-stak.git ${file}
    cd ${file}
    cmake ./ -DCUDA_ENABLE=OFF -DOpenCL_ENABLE=OFF && make install
    sysctl -w vm.nr_hugepages=128
    echo -e "soft memlock 262144\nhard memlock 262144" >> /etc/security/limits.conf
    cd ${file}/bin
    /usr/bin/expect <<-EOF
    spawn ./xmr-stak
    expect "*port number" {send "${x_port}\r" }
    expect "*enter the currency" {send "${x_currency}\r" }
    expect "*Pool address" {send "${x_address}\r" }
    expect "*Username" {send "${x_username}\r" }
    expect "*Password" {send "${x_passwd}\r" }
    expect "*Rig identifier" {send "${x_id}\r" }
    expect "*TLS/SSL" {send "${x_tls}\r" }
    expect "*nicehash" {send "${x_nicehash}\r" }
    expect "*multiple pools" {send "${x_multiple}\r" }
    interact
    expect eof
    EOF
    echo ' 配置完毕, xmr-stak 已启动...'
    
}
    
Run_xmr(){
    check_PID
    [[ -n ${PID} ]] && echo ' Error, xmr-stak 正在运行 !' && exit 1
    nohup .${file}/bin/xmr-stak &> /dev/null &
    check_PID
    [[ -n ${PID} ]] && echo ' xmr-stak 已启动 !'
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

clear
check_sys
[ $(id -u) != "0" ] && echo -e "Error: You must be root to run this script" && exit 1
echo -e " 出现问题请在 https://github.com/dovela/xmr-stak 处提issue
${sepa}
  1.首次安装并启动 xmr-stak
  2.运行 xmr-stak
  3.停止运行 xmr-stak
  4.首次安装linux依赖, 建议执行一次
  5.卸载 xmr-stak
${sepa}
  输入数字开始，或ctrl + c退出
"
echo && stty erase '^H' && read -p " 请输入数字[1-6]:" num
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
    Install_env
    ;;
    5)
    Remove_xmr
    ;;
    *)
    echo -e "Error, 请输入正确的数字 [1-6]!"
	;;
esac
