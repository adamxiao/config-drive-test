#qemu=/usr/libexec/qemu-kvm
qemu=qemu-system-x86_64
img=/opt/images/CentOS-7-x86_64-GenericCloud.qcow2

all:
	$(qemu) -m 2048 \
   -net nic -net user,hostfwd=tcp::2222-:22 \
   -drive file=boot-disk.img,if=virtio \
   -drive file=seed.iso,if=virtio \
   -vnc 0.0.0.0:0

clean:
	rm -f boot-disk.img
	qemu-img create -f qcow2 -b $(img) boot-disk.img

iso:
	@# config drive
	@#genisoimage -output seed.iso -volid config-2 -joliet -rock config-2
	@# nocloud
	genisoimage -output seed.iso -volid cidata -joliet -rock nocloud
