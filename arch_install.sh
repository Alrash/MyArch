#! /bin/sh

# # set time zone
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
hwclock --systohc --utc

# # set local gen
# en_US.UTF-8
# ja_JP.UTF-8
# zh_CN.UTF-8, zh_CN.GBK, zh_CN.GB18030, zh_CN.GB2312
# zh_TW.UTF-8
# zh_HK.UTF-8, zh_HK.BIG5-HKSCS
sed -i 's/^#en_US\.UTF/en_US\.UTF/g' /etc/locale.gen
sed -i 's/^#ja_JP\.UTF/ja_JP\.UTF/g' /etc/locale.gen
sed -i 's/^#zh_CN/zh_CN/g' /etc/locale.gen
sed -i 's/^#zh_TW\.UTF/zh_TW\.UTF/g' /etc/locale.gen
sed -i 's/^#zh_HK/zh_HK/g' /etc/locale.gen

locale-gen
# localectl set-locale LANG=en_US.UTF-8
echo 'LANG=en_US.UTF-8' > /etc/locale.conf

# # set hostname and hosts
HOSTNAME=alrash_workstation
echo $HOSTNAME > /etc/hostname

echo -e "\n127.0.0.1\tlocalhost" >> /etc/hosts
echo -e "::1\t\tlocalhost" >> /etc/hosts
echo -e "127.0.0.1\t$HOSTNAME.localdomain $HOSTNAME" >> /etc/hosts

# # make init linux kernel
# append nvme support and using xz compression
sed -i 's/MODULES=()/MODULES=(nvme)/g' /etc/mkinitcpio.conf
sed -i 's/^#COMPRESSION="xz"/COMPRESSION="xz"/g' /etc/mkinitcpio.conf

mkinitcpio -p linux

# # set root password and add new user
echo -n "please input root passwd: "
read PASSWD
echo "root:$PASSWD" | chpasswd
echo "update root password successfully."

echo -n "please input new user name: "
read USER
echo -n "please input user[$USER] passwd: "
read PASSWD
useradd -m -G wheel,audio,video -s /bin/zsh alrash
echo "$USER:$PASSWD" | chpasswd
echo "create user[$USER] and update password successfully."

# uncomment %wheel in /etc/sudoers
sed -i "s/^# %wheel ALL=(ALL) ALL$/%wheel ALL=(ALL) ALL/g" /etc/sudoers

# # install efibootmgr
pacman -S refind-efi efibootmgr --noconfirm
# manual refind install
ROOT_DEV=$(cat /etc/mtab | grep ' / ' | cut -d' ' -f1)
BOOT_DEV=$(cat /etc/mtab | grep '/boot' | cut -d' ' -f1)
PARTUUID=$(blkid -s PARTUUID -o value $ROOT_DEV)

# copy refind from /usr/share to /boot/EFI
mkdir -p /boot/EFI/refind/themes
git clone https://github.com/Lindstream/dm-refind-theme.git
cp -r ./dm-refind-theme /boot/EFI/refind/themes/
rm -rf dm-refind-theme

cp /usr/share/refind/refind_x64.efi /boot/EFI/refind/
# cp /boot/EFI/refind/refind_x64.efi /boot/EFI/Boot/bootx64.efi
cp ./conf/refind.conf /boot/EFI/refind/refind.conf
cp -r /usr/share/refind/icons /boot/EFI/refind/
cp -r /usr/share/refind/fonts /boot/EFI/refind/

sed -i "s/{{PARTUUID}}/$PARTUUID/g" /boot/EFI/refind/refind.conf

# write config file to /boot/refind_linux.conf
echo -e "\"Boot using default options\"\t\"root=PARTUUID=$PARTUUID rw add_efi_memmap initrd=/boot/initramfs-linux.img\"" > /boot/refind_linux.conf
echo -e "\"Boot using fallbak initramfs\"\t\"root=PARTUUID=$PARTUUID rw add_efi_memmap initrd=/boot/initramfs-linux-fallback.img\"" >> /boot/refind_linux.conf
echo -e "\"Boot to terminal\"\t\t\"root=PARTUUID=$PARTUUID rw add_efi_memmap initrd=/boot/initramfs-linux.img\" systemd.unit=multi-user.target" >> /boot/refind_linux.conf

efibootmgr -c -d ${BOOT_DEV:1:(-1)} -p ${BOOT_DEV:(-1)} -l /EFI/refind/refind_x64.efi -L "refind"


# #### myself config ####
# # aur
echo -e "\n[archlinuxcn]" >> /etc/pacman.conf
echo 'Server = https://mirrors.tuna.tsinghua.edu.cn/archlinuxcn/$arch' >> /etc/pacman.conf
pacman -Sy archlinuxcn-keyring --noconfirm
rm -rf /etc/pacman.d/gnupg
pacman-key --init
pacman-key --populate archlinux && pacman-key --populate archlinuxcn
pacman -S yay wget --noconfirm

# # i3wm
pacman -S xf86-video-intel i3 rofi feh compton rxvt-unicode tmux xorg-server xorg-xinit --noconfirm
pacman -S lightdm lightdm-gtk-greeter --noconfirm
sed -i "s/^#greeter-session=$/greeter-session=lightdm-gtk-greeter/g" /etc/lightdm/lightdm.conf
systemctl enable lightdm

# # fonts
pacman -S noto-fonts-cjk noto-fonts-emoji noto-fonts adobe-scoure-sans-pro-fonts wqy-zenhei wqy-mircohei --noconfirm

# # others
pacman -S chromium --noconfirm

# su user
#su $USER