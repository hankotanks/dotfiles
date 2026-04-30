echo "$USER" > /tmp/non_root_user
su -
apt update && apt upgrade
apt install -y --no-install-recommends sudo
usermod -aG sudo $(cat /tmp/non_root_user)
logout
