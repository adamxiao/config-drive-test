qemu=/usr/libexec/qemu-kvm
#qemu=qemu-system-x86_64
#qemu=qemu-kvm
img=/iso/CentOS-7-x86_64-GenericCloud-2009.qcow2
win2012=/iso/windows_server_2012_r2_standard_eval_kvm_20170321.qcow2

all: win

clean: win_clean

centos:
	$(qemu) -m 2048 \
   -net nic -net user,hostfwd=tcp::2222-:22 \
   -drive file=boot-disk.img,if=virtio \
   -drive file=seed.iso,if=virtio \
   -vnc 0.0.0.0:0

win:
	$(qemu) -m 2048 \
   -net nic -net user,hostfwd=tcp::2222-:22 \
   -drive file=boot-disk.img,if=virtio \
   -drive file=seed.iso,if=virtio \
   -vnc 0.0.0.0:0

win_clean:
	rm -f boot-disk.img
	qemu-img create -f qcow2 -b $(win2012) boot-disk.img

centos_clean:
	rm -f boot-disk.img
	qemu-img create -f qcow2 -b $(img) boot-disk.img

iso:
	@#genisoimage -output seed.iso -volid cidata -joliet -rock nocloud
	genisoimage -output seed.iso -volid config-2 -joliet -rock config-2.new
