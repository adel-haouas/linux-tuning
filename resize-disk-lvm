#resize existing disk

#add more capacity to disk from vm -> edit settings

fdisk -l /dev/sda

fdisk /dev/sda
d
2
n
p
2
t
2
8e
w
reboot

pvresize /dev/sda2

lvextend -L+1G /dev/centos/swap
swapoff -v /dev/centos/swap
mkswap /dev/centos/swap
swapon -va

lvextend -l +100%FREE  /dev/centos/root
xfs_growfs  /dev/centos/root

#in case of ext4
resize2fs /dev/centos/root

#verify
df -hT;echo;free -mh
