[//]: # (README.md)
[//]: # (Copyright © 2024 Joel A Mussman. All rights reserved.)
[//]: #

![Banner Light](https://raw.githubusercontent.com/jmussman/cdn-fun/main/banners/banner-k8s-install-scripts-light.png#gh-light-mode-only)
![Banner Light](https://raw.githubusercontent.com/jmussman/cdn-fun/main/banners/banner-k8s-install-scripts-dark.png#gh-dark-mode-only)

# Kubernetes Install Scripts

## Overview

There are significant steps to installing Kubernetes: update the package manager, add repositories, change 
system settings, create configurations, etc.
A course I was working with required the participants to perform the same steps multiple times to get
the configuration on each cluster node.
And, the instructions were out of date!
While installing Kubernetes once is a good learning experience, scripting it for the other nodes really is a must.

Different systems have different requirements.
This project is a container for different scripts to install in different environments.

These scripts is provided under the MIT license, "as-is", and without any warranty.
Administrators should test these scripts in a sandbox before trying to use it in production!

## Configuration

1. Copy the appropriate script to the computer where you need to install.
1. Run the script as an administrator, e.g.: sudo bash ubuntu-install-k8s.sh

## Ubuntu
### ubuntu-install-k8s.sh

* Package management updated to use gpg instead of apt-key and apt-repository, as they are deprecated and being removed.
* Repositories updated to use https://pkgs.k8s.io since the Google k8s repositories were end-of-lifed 3/4/2024.
* containerd and CRI *enabled*.

## See Also

* The Kubernetes certificates renewal script at https://github.com/jmussman/renew-k8s-certificates 

## License

The code is licensed under the MIT license. You may use and modify all or part of it as you choose, as long as attribution to the source is provided per the license. See the details in the [license file](./LICENSE.md) or at the [Open Source Initiative](https://opensource.org/licenses/MIT).


<hr>
Copyright © 2024 Joel A Mussman. All rights reserved.