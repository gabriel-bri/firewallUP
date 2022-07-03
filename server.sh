#!/bin/bash

#Verifica se o script está sendo rodado no modo root, caso contrário
#informa ao usuário que ele precisa de privilégios.
if [[ $USER == "root" ]]; then
    echo "[+] Configurando o Firewall..."

    #Interface bridge.
    placa1=`ip a | awk -F : '{print $2}' | grep "en" | head -n 1`
    #Interface host-only.
    placa2=`ip a | awk -F : '{print $2}' | grep "en" | tail -n 1`

    #Faz com que as duas placas sejam ativadas.
    ip link set $placa1 up
    ip link set $placa2 up

    #Faz com que a placa host-only faça a busca DHCP por IP.
    dhclient $placa2

    #Ativa o encanmihamento de pacotes.
    echo 1 > /proc/sys/net/ipv4/ip_forward
    
    #Adiciona uma regra no IPTABLES para a interface bridge.
    iptables -t nat -A POSTROUTING -o $placa1 -j MASQUERADE

else
    #Mensagem de erro.
    echo "Você precisa executar este script como root."
fi
