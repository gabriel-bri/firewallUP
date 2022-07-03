#!/bin/bash

if [[ $USER == "root" ]]; then
    echo "[+] Configurando o Firewall..."

    placa1=`ip a| awk -F : '{print $2}' | grep "en" | head -n 1`
    placa2=`ip a| awk -F : '{print $2}' | grep "en" | tail -n 1`

    ip link set $placa1 up
    ip link set $placa2 up
    dhclient $placa2

    echo 1 > /proc/sys/net/ipv4/ip_forward
    iptables -t nat -A POSTROUTING -o $placa1 -j MASQUERADE

else
    echo "Você precisa executar este script como root."
fi
