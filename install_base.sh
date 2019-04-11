#! /bin/sh

# # parted disk
# mkfs.ext4 /dev/sd{aX,bM}
# mount /dev/sdaX /mnt
# mkdir /mnt/{home,esp}
# mount /dev/sdaY /mnt/esp  # windows uefi part
# mount /dev/sdbM /mnt/home # home device

# # # uefi
# mkdir /mnt/boot
# mkdir /mnt/esp/EFI/Arch
# mount --bind /mnt/esp/EFI/Arch /mnt/boot

# # swap, tmp, var part
OTHER_ROOT=/mnt/home/os
mkdir /mnt/{var,tmp}
mkdir -p $OTHER_ROOT/{var,tmp}
# swap
dd if=/dev/zero of=$OTHER_ROOT/swapfile bs=1G count=2
mkswap $OTHER_ROOT/swapfile
swapon $OTHER_ROOT/swapfile
# tmp and var dir
mount --bind $OTHER_ROOT/var /mnt/var
mount --bind $OTHER_ROOT/tmp /mnt/tmp

# # add mirror servers to /etc/pacman.d/mirrorlist
# echo "Server = https://mirrors.tuna.tsinghua.edu.cn/archlinux/$repo/os/$arch" > /etc/pacman.d/mirrorlist
# echo "Server = https://mirrors.ustc.edu.cn/archlinux/$repo/os/$arch" >> /etc/pacman.d/mirrorlist
# echo "Server = https://mirrors.163.com/archlinux/$repo/os/$arch" >> /etc/pacman.d/mirrorlist
sed -i '1iServer = https://mirrors.163.com/archlinux/$repo/os/$arch' /etc/pacman.d/mirrorlist
sed -i '1iServer = https://mirrors.ustc.edu.cn/archlinux/$repo/os/$arch' /etc/pacman.d/mirrorlist
sed -i '1iServer = https://mirrors.tuna.tsinghua.edu.cn/archlinux/$repo/os/$arch' /etc/pacman.d/mirrorlist

# # update repo and install base os
pacman -Sy
pacstrap /mnt -i base base-devel vim zsh git

# # generate fstab list, and then remove /mnt
genfstab -U /mnt >> /mnt/etc/fstab
sed -i "s/\/mnt//g" /mnt/etc/fstab

# # copy arch_install.sh to /mnt
cp arch_install.sh /mnt