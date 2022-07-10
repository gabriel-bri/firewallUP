#!/bin/bash

#Verifica se o script está sendo rodado no modo root, caso contrário
#informa ao usuário que ele precisa de privilégios.
if [[ $USER == "root" ]]; then

    echo -e " --------------------------------------- "
    echo
    sleep 1
    echo -e "\033[31;7;5;107m [+] \033[0m Configurando o Firewall..."
    echo
    sleep 1
    echo -e " --------------------------------------- "

    #Interface bridge.
    placa1=`ip a | awk -F : '{print $2}' | grep "en" | head -n 1`
    #Interface host-only.
    placa2=`ip a | awk -F : '{print $2}' | grep "en" | head -n 2 | tail -n 1`
    #Interface host-only
    placa3=`ip a | awk -F : '{print $2}' | grep "en" | tail -n 1`

    #Faz com que as duas placas sejam ativadas.
    echo "[+] Ativando placa 1."
    ip link set $placa1 up
    echo "[+] Ativando placa 2."
    ip link set $placa2 up
    echo "[+] Ativando placa 3."
    ip link set $placa3 up

    #Faz com que as placa host-only faça a busca DHCP por IP.
    echo "[+] Realizando requisição por IP na placa 2."
    dhclient $placa2

    echo "[+] Realizando requisição por IP na placa 3."
    dhclient $placa3

    #Bloqueando conexões no iptables.
    echo "[+] Bloqueando conexões no servidor."
    iptables -P INPUT DROP
    iptables -P FORWARD DROP
    iptables -P OUTPUT DROP
    
    #Liberando conexõe SSH.
    echo "[+] Liberando conexão SSH na porta 22."
    iptables -A INPUT -p tcp -m tcp --dport 22 -j ACCEPT
    iptables -A OUTPUT -p tcp -m tcp --sport 22 -j ACCEPT

    #Ativa o encanmihamento de pacotes.
    echo "[+] Ativando encaminhamento de pacotes."
    echo 1 > /proc/sys/net/ipv4/ip_forward

    #Adiciona uma regra no IPTABLES para a interface bridge.
    echo "[+] Adicionando mascaramento IP."
    iptables -t nat -A POSTROUTING -o $placa1 -j MASQUERADE

    echo "[+] Recarregando arquivos de configuração do Squid."
    sudo invoke-rc.d squid reload

    echo "[+] Reiniciando o Squid..."
    sudo invoke-rc.d squid restart
#ip a | grep en | grep inet |  awk -F  " '{print $2}
#ipcalc $ip | grep Network |  awk -F  " '{print $2}

else
    #Mensagem de erro.
    echo "Você precisa executar este script como root."
fi
