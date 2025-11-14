#cloud-config
runcmd:
  - sed -i 's/^#Port 22/Port 2025/' /etc/ssh/sshd_config
  - systemctl restart sshd