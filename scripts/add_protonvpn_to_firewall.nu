# Every Proton VPN IP Address is added to the firewall exemption list
ls /etc/openvpn/client/protonvpn_*.conf | each --flatten { open $in.name | lines | where $in =~ "^remote " } | each { $in | parse "remote {ip} {port}" | get 0 } | each { ufw allow out to $in.ip port $in.port proto udp }
