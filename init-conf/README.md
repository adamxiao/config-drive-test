# 初始化配置示范

## FAQ

1. 为什么用vendor_data.json, 而不是user-data? 
2. 为什么用hostnamectl设置主机名, 而不是meta_data的hostname变量?
3. 为什么用windows配置网卡ip，不需要mac地址?
4. windows使用libvirt安装总是失败? => 重点处理


centos-only-passwd
仅仅配置root密码

centos-only-passwd2
仅仅配置cloud用户的密码(centos云镜像默认配置为centos)

centos-only-hostname
仅仅配置主机名

centos-only-ip
仅仅配置静态ip地址
参考 https://specs.openstack.org/openstack/nova-specs/specs/liberty/implemented/metadata-service-network-info.html

win-only-passwd
仅仅配置windows的密码

win-only-hostname
仅仅配置windows的主机名

win-only-ip
仅仅配置windows的主机名
