#!/bin/bash
#
# ubuntu-install-k8s
# Copyright (c) Joel A Mussman. All rights reserved.
#
# This script is released under the MIT license (https://opensource.org/license/mit) and
# may be copied, used, and altered as long as attribution is provided. This software is
# provided "as-is" without warranty. It should be tested by the user before running in
# production.
#
# This script is intended to be run as root: sudo bash ubuntu-install-k8s.sh.
#
# This script accomplishes the Kubernetes installation up to the point of creating
# a master or joining a cluster.
#
# Ubuntu dependencies:
#	apt v1.3+
#	gpg
#

#
# setRepo will load the signing key and repository with three arguments:
#   1. The local name of the repository
#   2. The URL to the key file (GPG or PGP)
#   3. The URL to the repository
#

addRepo()
{
	# Expect repo name ("kubernetes"), key URL, and definition for the repo source.

	# This replaces apt-get, since apt-get and apt-repository are being deprecated in Linux.
	# Get the key, if it is PGP convert to GPG, and write the key to a file. Write the repository
	# defition to a a file that apt can find (with a link to the key).

	keyring=/usr/share/keyrings/$1.gpg

	if [[ -f $keyring ]]; then

		mv $keyring $keyring.save
	fi

	if [[ ! -z $(curl -fsSL $2 | grep "BEGIN PGP PUBLIC KEY BLOCK") ]]; then

		curl -fsSL $2 | gpg --dearmor -o $keyring

	else

		curl -fsSL $2 > $keyring
	fi

	# If the definition does not have options [], add the option that points to
	# the keyring; if it does have options, add the keyring to the existing options.

	def="$3"

	if [[ -z $(echo "$def" | grep "]") ]]; then

		def=$(echo "$def" | sed -e "s|deb |deb [signed-by=$keyring] |")

	else

		def=$(echo "$def" | sed -e "s|]| signed-by=$keyring]|")

	fi

	echo "$def" > /etc/apt/sources.list.d/$1.list
}

#
# Add the package repositories and update apt.
#

echo
echo "Update apt and prepare for additional repositories."

apt update
apt -y install curl gnupg2 apt-transport-https software-properties-common ca-certificates

echo
echo "Add Kubernetes and Docker repositories."

# addRepo "dl-ssl.google" "https://dl-ssl.google.com/linux/linux_signing_key.pub" ""

addRepo "kubernetes" "https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key" \
	"deb https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /"

addRepo "docker" "https://download.docker.com/linux/ubuntu/gpg" \
	"deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

apt update

echo
echo "Install Kubernetes, containerd, and Docker."

apt install -y vim git wget kubelet kubeadm kubectl containerd.io docker-ce docker-ce-cli
apt-mark hold kubelet kubeadm kubectl

echo
echo "Verify Kubernetes versions:"

kubectl version --client
kubeadm version

#
# Swap and Kubernetes are incomplatible (some compatibility changes are in beta).
#

echo
echo "Disable swap."

swapoff -a
sed -i '/^\/swap/ s/\(.*\)/#\1/g' /etc/fstab

#
#
#

echo
echo "Enable the Linux Overlay Filesystem and br_netfiler for filtering required by iptables."

modprobe overlay
modprobe br_netfilter

#
# Create Kubernetes service configuration and reload kernel modules.
#

echo
echo "Update kubernetes configuration for network filters."

tee /etc/sysctl.d/kubernetes.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

sysctl --system

#
# Configure Docker
#

echo
echo "Configure Docker and relaod services."

tee /etc/docker/daemon.json <<EOF
{
	"exec-opts": [ "native.cgropudriver=systemd" ],
	"log-driver": "json-file",
	"log-opts": {
		"max-size": "100m"
	},
	"storage-driver": "overlay2"
}
EOF

systemctl daemon-reload
systemctl restart docker
systemctl enable docker

#
# Enable the CRI plugin used by current Kubernetes versions for containerd.
#

echo
echo "Enable CRI plugin for containerd."

sed -i '/^#disabled_plugins/ s/^#\(.*\)/\1/g' /etc/containerd/config.toml
systemctl restart containerd

echo
echo "Finished."
