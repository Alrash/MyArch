#! /bin/sh

# # set time zone
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

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

echo "\n127.0.0.1\tlocalhost" >> /etc/hosts
echo "::1\t\tlocalhost" >> /etc/hosts
echo "127.0.0.1\t$HOSTNAME.localdomain $HOSTNAME" >> /etc/hosts

# # make init linux kernel
# append nvme support and using xz compression
sed -i 's/MODULES=\(\)/MODULES=\(nmve\)/g' /etc/mkinitcpio.conf
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
pacman -S refind-efi efibootmgr
refind-install --usedefault /dev/sda2
efibootmgr -c -d /dev/sda -p 2 -l /EFI/refind/refind_x64.efi -L "rEFInd"