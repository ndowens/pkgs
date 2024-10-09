#!/bin/bash
for i in mirrorlists/cachyos-* mirrorlists/chaotic-mirrorlist mirrorlists/mirrorlist ; do
	cp $i /etc/pacman.d
done

cp mirrorlists/pacman.conf /etc/pacman.conf
useradd -mG users bob
passwd -d bob
yes | pacman -Sy pacman-static
echo "n" | yes | pacman-static -S zlib
yes | pacman -Syu --noconfirm

sed -i '/PKGDEST/d' /etc/makepkg.conf
cat << EOF >> /etc/makepkg.conf
PKGDEST=/builds/ndowens/PKGBUILDs/public
EOF

cat <<EOF >> /etc/sudoers
bob ALL=(ALL:ALL) NOPASSWD: ALL
EOF
PKGS="$(echo $PKGS | sed -e /SRCINFO/d)"

for i in $PKGS ; do
    cd $i
	if [[ ! -e usegcc ]]; then
       pacman -S clang lld llvm --noconfirm
       export CC=clang
       export CXX=clang++
       export LD=lld
    fi
	sudo -u bob makepkg -si  --noconfirm
    cd  ../..
done