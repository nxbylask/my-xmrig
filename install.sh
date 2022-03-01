sudo apt update
sudo apt upgrade -y

cd /home/nxbylask/
apt-get install git build-essential cmake automake libtool autoconf -y
git clone https://github.com/xmrig/xmrig.git; mkdir xmrig/build && cd xmrig/scripts
./build_deps.sh
cd ../build
cmake .. -DXMRIG_DEPS=scripts/deps
make -j$(nproc)

cd /home/nxbylask/
# need to include configuration for 4/8 vcpu
cp my-xmrig/config-8-vcpu.json xmrig/build/config.json
cp my-xmrig/xmrig.service /etc/systemd/system/xmrig.service

chmod 777 /etc/systemd/system/xmrig.service
systemctl enable xmrig.service
systemctl start xmrig.service
