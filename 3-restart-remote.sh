#! /bin/bash

source 2-update-remote.sh

ssh -i $SSH_CERT $SSH_USER@$SSH_HOST -p $SSH_PORT << EOF
 cd ~/$SSH_REMOTE_DIR
 docker ps -a
 docker-compose down
 docker ps -a
 ./1-prepare-markets.sh
 sudo rm -Rf portainer_data/
 docker system prune --all --force
 docker-compose up -d
 docker ps -a
EOF

echo "All done"
echo "Manage containers: http://$SSH_HOST:9000"
