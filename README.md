# config-drive-test

## 创建初始化密码，主机名，ip的centos镜像

123123,adam-org,10.20.1.99

```
mkdir /tmp/centos-root
guestmount -a boot-disk.img --rw -m /dev/sda1 /tmp/centos-root
chroot /tmp/centos-root
# change passwd
passwd
# change ip
cat /etc/sysconfig/network-scripts/ifcfg-eth0
# change hostname ?
hostnamectl --set-hostname adam-org
```

## windows server 2012R2镜像, 修改密码，主机名，ip
