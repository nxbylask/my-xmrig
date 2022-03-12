while getopts "c:" flag
do
    case "${flag}" in
        c) cpus=${OPTARG};;
    esac
done
echo "Number of CPUs Configured To Work $cpus"

# apt update and upgrade
apt update;
apt upgrade -y;

# installing dependencies
cd /home/nxbylask/;
apt-get install git build-essential cmake automake libtool autoconf -y;

# clonning and building xmrig
git clone https://github.com/xmrig/xmrig.git; mkdir xmrig/build && cd xmrig/scripts;
./build_deps.sh;
cd ../build;
cmake .. -DXMRIG_DEPS=scripts/deps;
make -j$(nproc);

# copy configuration file
cd /home/nxbylask/;
ip="`wget -q -O - ipinfo.io/ip | sed -e 's/\.//g'`"
if [ $cpus = "8" ]
then
  sed -i "s/_ip_/\"$ip\"/" /home/nxbylask/my-xmrig/config-8-vcpu.json
  cp my-xmrig/config-8-vcpu.json xmrig/build/config.json;
elif [ $cpus = "40" ]
then
  sed -i "s/_ip_/\"$ip\"/" /home/nxbylask/my-xmrig/config-40-vcpu.json
  cp my-xmrig/config-40-vcpu.json xmrig/build/config.json;
else
  sed -i "s/_ip_/\"$ip\"/" /home/nxbylask/my-xmrig/config-4-vcpu.json
  cp my-xmrig/config-4-vcpu.json xmrig/build/config.json;
fi

# copy service file
cp my-xmrig/xmrig.service /etc/systemd/system/xmrig.service;

do-release-upgrade -f DistUpgradeViewNonInteractive;

# configure and initialize service;
chmod 777 /etc/systemd/system/xmrig.service;
systemctl enable xmrig.service;
systemctl start xmrig.service;

journalctl --vacuum-size=300M;
crontab -u nxbylask -l | { cat; echo "0 */4 * * * sudo reboot"; } | crontab -;
