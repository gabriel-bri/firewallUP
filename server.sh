#!/bin/bash

#Verifica se o script está sendo rodado no modo root, caso contrário
#informa ao usuário que ele precisa de privilégios.
if [[ $USER == "root" ]]; then

    echo -e " --------------------------------------- "
    echo
    sleep 1
    echo -e " \033[31;7;5;107m [+] \033[0m Configurando o Firewall..."
    echo
    sleep 1
    echo -e " --------------------------------------- "

    #Interface bridge.
    placa1=`ip a | awk -F : '{print $2}' | grep "en" | head -n 1`
    #Interface host-only.
    placa2=`ip a | awk -F : '{print $2}' | grep "en" | tail -n 1`

    #Faz com que as duas placas sejam ativadas.
    echo "[+] Ativando placa 1."
    ip link set $placa1 up
    echo "[+] Ativando placa 2."
    ip link set $placa2 up

    #Faz com que a placa host-only faça a busca DHCP por IP.
    echo "Realizando requisição por IP na placa 2."
    dhclient $placa2
        
    #Bloqueando conexões no iptables.
    echo "[+] Bloqueando conexões no servidor."
    iptables -P INPUT DROP
    iptables -P FORWARD DROP
    iptables -P OUTPUT DROP

    #Ativa o encanmihamento de pacotes.
    echo 1 > /proc/sys/net/ipv4/ip_forward

    #Adiciona uma regra no IPTABLES para a interface bridge.
    iptables -t nat -A POSTROUTING -o $placa1 -j MASQUERADE

else
    #Mensagem de erro.
    echo "Você precisa executar este script como root."
fi
