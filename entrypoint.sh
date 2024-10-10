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
PKGDEST=public
EOF

cat <<EOF >> /etc/sudoers
bob ALL=(ALL:ALL) NOPASSWD: ALL
EOF

#export COMMIT_BEFORE_SHA="$(git rev-parse HEAD~1)"
#export COMMIT_SHA="$(git rev-parse HEAD~0)"
#export PKGS=$(git diff $COMMIT_BEFORE_SHA $COMMIT_SHA --name-only | sed -e s,PKGBUILD,,)

#export PKGS="$(git diff HEAD~1..HEAD~2 --name-only | sed -e s,PKGBUILD,,)"

#export PKGS="$PKGS | sed -e /SRCINFO/d"
#export PKGS="$(find packages/* -cmin -1 -mmin -1 -type d)"
#export PKGS="$(echo $PKGS | sed -e 's,PKGBUILD,,' -e 's|\.SRCINFO||')"

for i in $PKGS ; do
    sudo chown bob -R $i
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
