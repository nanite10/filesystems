#!/bin/bash

dnf update -y
dnf groupinstall "Development Tools" -y
dnf install ncurses-devel hmaccalc zlib-devel binutils-devel elfutils-libelf-devel kernel-devel kernel-headers asciidoc audit-libs-devel bash bc binutils binutils-devel bison diffutils elfutils elfutils-devel elfutils-libelf-devel findutils flex gawk gcc gettext gzip hmaccalc hostname java-devel m4 make module-init-tools ncurses-devel net-tools newt-devel numactl-devel openssl patch pciutils-devel perl perl-ExtUtils-Embed pesign python36 python36-devel python3-docutils redhat-rpm-config rpm-build sh-utils tar xmlto xz zlib-devel wget kabi-dw libcap-devel libcap-ng-devel llvm-toolset openssl-devel -y
mkdir -p ~/rpmbuild/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS}
echo '%_topdir %(echo $HOME)/rpmbuild' > ~/.rpmmacros
cos_release=`cat /etc/centos-release | tr -dc '0-9.'`
kernel_release=`uname -r | sed 's/^/kernel-/g' | sed 's/\.x86_64$//g'`
if ! [ -e kernel-4.18.0-147.3.1.el8_1.src.rpm ]; then wget http://vault.centos.org/${cos_release}/BaseOS/Source/SPackages/${kernel_release}.src.rpm; fi
if ! rpm -qa | grep -qi $kernel_release.src.rpm; then rpm -i $kernel_release.src.rpm; fi
sed -i 's/.*CONFIG_XFS_RT.*/CONFIG_XFS_RT=y/g' ~/rpmbuild/SOURCES/kernel-x86_64.config
cd ~/rpmbuild/SPECS
rpmbuild -bb --target=$(uname -m) kernel.spec > ~/rpmbuild/kernel_build.log 2>~/rpmbuild/kernel_build_error.log
