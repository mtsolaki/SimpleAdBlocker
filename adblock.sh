#!/bin/bash
# You are NOT allowed to change the files' names!
domainNames="domainNames.txt"
IPAddresses="IPAddresses.txt"
adblockRules="adblockRules"

function getIPs() {
    while read domain
    do
        nslookup $domain -timeout=0.1 -type=A | grep Address | sed 1d | sed "s/^.*\(Address: \)//g" >> $IPAddresses
        
    done < $domainNames
}

function setTable() {
    while read ip
    do 
        iptables -A INPUT -s $ip -j REJECT

    done < $IPAddresses
}

function adBlock() {
    if [ "$EUID" -ne 0 ];then
        printf "Please run as root.\n"
        exit 1
    fi
    if [ "$1" = "-domains"  ]; then

        rm  IPAddresses.txt
        getIPs
        setTable

        true
            
    elif [ "$1" = "-ips"  ]; then
        
        setTable

        true
        
    elif [ "$1" = "-save"  ]; then
        
        iptables-save > adblockRules
        true
        
    elif [ "$1" = "-load"  ]; then

        iptables-restore < adblockRules
        true

        
    elif [ "$1" = "-reset"  ]; then

        rm -f adblockRules
        iptables -F
        true

        
    elif [ "$1" = "-list"  ]; then
        
        iptables -L
        true
        
    elif [ "$1" = "-help"  ]; then
        printf "This script is responsible for creating a simple adblock mechanism. It rejects connections from specific domain names or IP addresses using iptables.\n\n"
        printf "Usage: $0  [OPTION]\n\n"
        printf "Options:\n\n"
        printf "  -domains\t  Configure adblock rules based on the domain names of '$domainNames' file.\n"
        printf "  -ips\t\t  Configure adblock rules based on the IP addresses of '$IPAddresses' file.\n"
        printf "  -save\t\t  Save rules to '$adblockRules' file.\n"
        printf "  -load\t\t  Load rules from '$adblockRules' file.\n"
        printf "  -list\t\t  List current rules.\n"
        printf "  -reset\t  Reset rules to default settings (i.e. accept all).\n"
        printf "  -help\t\t  Display this help and exit.\n"
        exit 0
    else
        printf "Wrong argument. Exiting...\n"
        exit 1
    fi
}

adBlock $1
exit 0