#!/usr/bin/env bash

apt-get update -y && apt-get install -y python3.5 python3-dev python3-pip curl

mkdir -p /root/tensorboard

pip3 install --upgrade pip

pip3 install tensorflow==1.15 tensorboard==1.15

cat > /usr/sbin/tensorboard-sync.sh <<- "EOF"
#!/usr/bin/env bash
echo "crontab is working... for real!" >> /is-crontab-working.txt
gsutil -m rsync -d -r gs://edml/ai-platform/models/ /root/tensorboard/
EOF

cat > /usr/sbin/tensorboard-start.sh <<- "EOF"
#!/usr/bin/env bash
tensorboard --logdir=/root/tensorboard/ --port=80
EOF

cat > /lib/systemd/system/tensorboard.service <<- "EOF"
[Unit]
Description=Tensorboard Server
After=network.target
After=systemd-user-sessions.service
After=network-online.target

[Service]
User=root
ExecStart=/usr/sbin/tensorboard-start.sh
TimeoutSec=30
RestartSec=30
Restart=on-failure
StartLimitBurst=10
StartLimitInterval=350

[Install]
WantedBy=multi-user.target
EOF

chmod a+x /usr/sbin/tensorboard-sync.sh
chmod u+x /usr/sbin/tensorboard-start.sh

systemctl start tensorboard
systemctl enable tensorboard

echo "* * * * * root /usr/sbin/tensorboard-sync.sh" > /tmp/crontab-root
crontab -u root /tmp/crontab-root

/usr/sbin/tensorboard-sync.sh