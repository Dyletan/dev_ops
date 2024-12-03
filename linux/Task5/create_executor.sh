if id "executor" &>/dev/null; then
    echo "User 'executor' already exists. Skipping user creation."
    exit 0
else
    adduser --system --no-create-home --shell /bin/bash executor
    echo "User 'executor' created."
fi

PROJECT_DIR="/home/linux/Task4"
apt-get install acl
setfacl -R -m u:executor:rx $PROJECT_DIR
getfacl $PROJECT_DIR
echo "User executor created"