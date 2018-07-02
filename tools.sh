sudo apt update
sudo apt install -y snapd
sudo snap install rg
wget https://github.com/sharkdp/fd/releases/download/v7.0.0/fd-musl_7.0.0_i386.deb
sudo dpkg -i fd-musl_7.0.0_i386.deb
rm fd-musl_7.0.0_i386.deb
sudo apt install -y silversearcher-ag
sudo apt upgrade -y snapd silversearcher-ag
sudo snap refresh rg
