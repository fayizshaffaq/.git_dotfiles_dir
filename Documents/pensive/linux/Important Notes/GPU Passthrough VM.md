
# this is incomplete 
### Looking Glass: 
> Looking Glass is an open source application that allows the use of a KVM (Kernel-based Virtual Machine) configured for VGA PCI Pass-through without an attached physical monitor, keyboard or mouse. This is the final step required to move away from dual booting with other operating systems for legacy programs that require high performance graphics.

OVMF - open virtual machine framework 

VFIO - 
virt-manager virt-viewer qemu vde2 ebtables iptables-nft n
ftables dnsmasq bridge-utils ovmf swtpm

IOMMU 
> INPUT OUTPUT MEMORY MANAGEMENT UNIT

qemu
KVM/QEMU/Libvirt/OVMF
kvm
> kernal based virtual machine.

VFIO (Virtual Function I/O):
> This is the Linux kernel driver that lets a VM directly control a real PCI device.

vfio-pci.
> This is a VFIO driver, meaning it fulfills the same role as pci-stub did, but it can also control devices to an extent, such as by switching them into their D3 state when they are not in use. 

Providing the device IDs is done via the kernel module parameter ids=10de:13c2,10de:0fbb for vfio-pci. 

PCI passthrough via OVMF


editing grub file 

intel VT-x 
intel VT-d

> stands for Intel Virtualization Technology for Directed I/O and should not be confused with VT-x Intel Virtualization Technology. VT-x allows one hardware platform to function as multiple “virtual” platforms while VT-d improves security and reliability of the systems and also improves performance of I/O devices in vitalized environments.

cpu support for IOMMU
motherboard/bios support for IOMMU
GPU ROM must support UEFI






IOMMU is a generic name for Intel VT-d and AMD-Vi

IOMMU VS DMA? 



IOMMU Group 15:
	0000:01:00.0 VGA compatible controller [0300]: NVIDIA Corporation GA107M [GeForce RTX 3050 Ti Mobile] [10de:25a0] (rev a1) [10de:25a0]
	0000:01:00.1 Audio device [0403]: NVIDIA Corporation GA107 High Definition Audio Controller [10de:2291] (rev a1) 
0000:01:00.0 VGA compatible controller [0300]: NVIDIA Corporation GA107M 

[GeForce RTX 3050 Ti Mobile] [10de:25a0] (rev a1)
	Subsystem: ASUSTeK Computer Inc. Device [1043:1ccc]
	Kernel driver in use: nvidia
	Kernel modules: nouveau, nvidia_drm, nvidia
0000:01:00.1 Audio device [0403]: NVIDIA Corporation GA107 High Definition Audio Controller [10de:2291] (rev a1)
	Subsystem: ASUSTeK Computer Inc. Device [1043:1ccc]
	Kernel driver in use: snd_hda_intel
	Kernel modules: snd_hda_intel