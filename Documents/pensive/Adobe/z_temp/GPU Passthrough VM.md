### Looking Glass: 
> Looking Glass is an open source application that allows the use of a KVM (Kernel-based Virtual Machine) configured for VGA PCI Pass-through without an attached physical monitor, keyboard or mouse. This is the final step required to move away from dual booting with other operating systems for legacy programs that require high performance graphics.

OVMF - open virtual machine framework 

VFIO - 
virt-manager virt-viewer qemu vde2 ebtables iptables-nft n
ftables dnsmasq bridge-utils ovmf swtpm

IOMMU 
> INPUT OUTPUT MEMORY MANAGEMENT UNIT

qemu

kvm
> kernal based virtual machine.

vfio

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