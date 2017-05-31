## Abstract

A stateless environment based on Gentoo, which aims on making the 
maintenance of multiple machines easier, improve stability and usability 
on environments like Research or University computer labs.


## An introduction to the stateless concept

To begin with, a stateless system, as a concept, is an operating system which can boot and operate without requiring to hold a “memory” of its last state. However, even as a concept, this raises many questions, and could make sceptical even someone which has spend a little time reading about the operation of Linux. That is because, such a system would have many operational restrictions. First of all, the system would be “frozen in time”, meaning that every time the system boots, is like booting for the first time, because no inner “advancement” is happening, that is, no previous timeline of changes and configurations exists.

How could such a system be used and what would be its aims to begin with? Why create something that does not advance while being used? Before answering those, I must note that the stateless concept is not new nor undeveloped, on the contrary, is something that exists and is very active, with many remarkable and active projects from well known organizations. 

The answer to the above is found on environments where the system’s integrity and continuous operation of it, is mandatory. A stateless system, while having many operational restrictions for a normal day to day use, can provide many perks for the above environments, because if you make something that works, and it does no have “memory” of the past, then, on each reboot the system keeps no changes that in the past could have led it being unstable or even completely broken.

There are many ways to make such a system, each of it having its own pros and cons. For example, booting your system on a ramdisk instantly provides you with all those good perks, because each reboot, resets everything. However that has a cost, that is, machines with limited amount of memory, e.g. embedded systems, can not use it.
 
An other famous options derives from the well known read-only root filesystem. That system has no need of a reset, because none needs to be made. Read-only means no writes leading to no changes, which in turn implies that it should not break, unless hardware failure is considered. 
Embedded systems can easily take advantage of this, knowing that the functions and features need to be supported, are limited by system’s definition. That system is created for a specific purpose and I believe that they adapt quite good at it.

On the other hand however, this would not be favoured by bigger systems, because those must use quite more functions and provide many more features, meaning that editing and patching everything that needs write permissions(if possible) can be time consuming and quite annoying if you imagine that those changes must be made each time the system updates (from the server).

The aim of this project is to create something that can be used by as many different systems as possible. For achieving this, a mixed version of the above methods will be considered. The root filesystem will be read-only while certain directories like /etc will be mounted as ramdisk, while some others as tempfs, e.g. /var. Ramdisk /var can be considered too, supposing that some of it’s inner directories will be kept clean, to keep it’s size at a minimum.

Apart from the system, this project will create additional services. Those for now are: A builder and a controller. The builder will lie on a central powerful machine, which will build the above system and prepare it for distribution.

The controller will be a initramfs image which will provide functions for creating new drive’s interfaces, creating filesystems, syncing the system which lies on the server to the local drives, determining how a system is considered healthy, which is the system’s backup partition and how the bootflag will change between those. More details, additional functions and configuration options will be discussed on the technical part later for both the controller and the builder.


#### Obstacles

Because the aims is to create a system which will support as many machines as possible, a kernel with build-in drives will grow in size quite fast, which is not desirable. To pass over this, an initramfs must be created or edited which will support a modular kernel while at the same time will host all the functions from which the controller is consisted.

Make config.d fetched files persistent

#### Expectations

A builder inside the server which will build a portable initramfs image, configured by the users needs from the config.d directory. The init-image could then be ported to a usb-drive, cd or any bootable medium and initiate the process. When done, the machine will be bootable and ready to use for the purpose it was created.

A future thought would be creating a service inside the machine which will be distributing the images. That services could support NFS mount for the purpose of installing the above initramfs image and kernel locally. Initially a boot from network would happen, then a message “no system image is found locally” would appear on the client’s screen. The user would be able to either choose to run the system as a diskless node, or to install the image locally. This would create a boot partition with everything needed to initiate the normal process.
 

#### Abstract Framework

- Read Only
     - /usr
     - /etc 1*
     - /bin
     - /lib
     - /opt
     - /var 2*

- Read – Write
     - /boot/
     - /boot/logs
     - /user-data/ 3*
<<<<<<< HEAD
  - /user-data/persistent
    - {local,rmount}
        - /local/{root,home,mnt,media}
      - {var,etc} 4*
- tmpfs
     - /user-data/tmpfs
      - {tmp,var,etc}
=======
	- /user-data/persistent
		- {local,rmount}
	  		- /local/{root,home,mnt,media}
	  	- {var,etc} 4*
- tmpfs
     - /user-data/tmpfs
     	- {tmp,var,etc}
>>>>>>> 47c93c45f8850c954111560b0da6f77dc251043b
     - /tmp
     - /var/tmp





#### Technical details

After the kernel has load the initramfs, a check script will be sourced. The script, initially will read the configuration files from the /config.d directory (a directory which will be updated from the server) and then scan the indicated filesystems for the one holding the boot flag. 
The boot flag will be a file which the initramfs configures each time a filesystem completes a healthy cycle (successful start up and shutdown), and will lie inside the root filesystem. 
Such a file can only be modified by the initramfs, and missing or modifying it manually will indicate a system corruption, immediately activating the boot flag switch over the backup system.

About the boot flag switch, I am thinking about supporting two methods. Under the /config.d directory, a file will either instruct the initramfs to instantly bailout and boot the backup filesystem or to use that backup partition for cloning it over the corrupted system. By this options, systems that must operate as soon as possible, will boot fast, while systems that can spare some time, will fix the damaged system without leading to a boot flag switch.

That file and many others would be configured by the administrator on the server which hosts the builder. The initramfs will always attempt to sync the config.d directory from the server, with its local one.

After determining which filesystem will be booted, a second source ver-control script will be initiated, which in turn will ask from the server about the latest version and compare it with the local. If the versions match then the process of mounting the rootfs will be initiated, if they are not, the updater will notify the user that the system needs to be updated, and ask for approval. This option could be switched of entirely if wished, to avoid the system hanging for approval on systems where human presence will be quite rare or even none existent.


#### The Controller

The controller will: 
```
-Create a custom initramfs 
-Create functions for the initramfs to: 
-Select the appropriate drives 
-Identify the current filysystem(if any) 
-Modify (create,delete) filesystems 
-Manage, modify and mount subvolumes (btrfs for now) 
-Identify network interface and initiate networking (wired) 
-Communicate with the server (e.g asking for latest version) 
-Sync the local root file system, with the server 
-Mount tmpfs, bind mounts and overlays 
-Create a local backup filesystem (now I am thinking to about using 
rsync, if btrfs is not an option) 
-Edit and create configs to make the filesystem functional on the local host 
-Determinate what is considered a healthy start up and shut down 
-Change boot partitions in case the health check fails or if system 
corruption occurred. 
-A self(initramfs) health-check. 
-Copy, compress and archive system logs (maybe on a subfolder inside 
the boot volume, which I find it dangerous for now) 
-Add the libraries and dependencies to the initramfs to support the tools to be used. 
-Integrate some general modules that could be used. 
eg: modules for the boot filesystem, if system logs are saved there 
```

#### System 
```
Create a minimal system (by bootsptrap??? script on /usr/portage/scripts) 
Configure the system to be functional and bootable 
Configure the system to function as readonly by 
-configure /var and /etc 
-tmpfs filesystems for some directories 
-using overlays 
-using aufs? 
Clean as many leftovers and unused files from the above steps
```
#### The system’s tree
```
/boot /dev /proc /sys /etc /usr {,s}bin /usr /lib{,32,64} /var /mnt /media /run /opt /home /root user-data/ /user-data/mnt /user-data/tmpfs-{etc,var,tmp}
/…/local/{data,home,root} /user-data/persistent/{etc,var,logs,config.d}
```
Symlinks
```
/etc      --> /user-data/tmpfs/etc
/var      --> /.../.../var
/tmp      --> /.../.../tmp
/root     --> /.../persistent/local/root
/home     --> /.../.../local/home
```
The entries following in the fstab below should not be considered. However they appear there for the case of going symlink-free. Exception makes /etc, which will always be mounted from the initramfs first, as a ramdisk and hence does not appear in the fstab.

Special files and directories could be copied over the persistent directory if they are considered important.

Read-Only early fstab framework
```
<fs>          <mountpoint>   <type>       <opts>                 <dump/pass>
/dev/sdaA         /boot        ext2/vfat     defaults                0       2
/dev/sdaX         /            ext4/btrfs    noatime,ro/subvol       0       1/0
/dev/sdaH         /user-data   ext4/btrfs    defaults/subvol         0       1/0
/dev/sdaH         /var/tmp     tmpfs         noexec,no...            0       0
/dev/sdaH         /var/logs*   tmpfs         noexec,no...            0       0
/dev/sdaH         /usr/tmp     tmpfs         noexec,no...            0       0
tmpfs             /tmp         tmpfs         noexec,no...            0       0
/dev/sdaH         /{home.root} ext4/btrfs    defaults/subvol         0       1/0
```
** log: User's choice






### About the builder

The builder will: 
```
Build the above system 
Build the above initramfs
Chroot and optimize the above system for the target architecture 
Prepare the above setup for distribution by either: 
-making a stage 4 tarball 
-making a snapshot 
-method not aware of yet 
A script which will: 
Integrate the above builder steps 
Check the builder directory for missing files which will sync missing files or all the directory from a remote web location. 
```

### The config.d directory

As mentioned earlier, this directory will hold configurations files. From those files the builder and initramfs will be able to execute special instructions instead of the preconfigured. For example, the builder will first search there for a make.conf file, and if it exists, then that will be the file to be used for the system optimization. The configurations files which the controller will ask from the server, will be hosted there.

An first view of the config.d is presented below, but keep in mind that those files could change and more could be added.
``` 
config.d
├── controller 
│   ├── btrfs.conf 
│   ├── cfstab.conf 
│   ├── drives.conf 
│   ├── examples 
│   ├── README 
│   ├── server 
│   │   └── server.info.conf 
│   ├── services 
│   │   └── default-runlevel 
│   ├── tmpfs.conf 
│   └── update.chk.conf 
├── README 
├── sources 
│   ├── README 
│   └── sources.conf 
└── system 
   ├── boot.conf 
   ├── etc.conf 
   ├── examples 
   ├── fstab.conf 
   ├── network.conf 
   ├── overlays.conf 
   └── README
```

Intuition should do a great job here, just by reading the name of each file, however there are some entries worth mentioning which could further reveal what could the controller achieve when used with config.d.

Under the controller sub-directory the server.info.conf file, will provide all the informations needed to further optimize the relations between initramfs and the server. Indications about the server and the tools to be used for the authentication will lie there. From that someone could make the builder under a machine A and indicate that all configurations files from now on, should be fetched from an alternative machine B. This method provides a tool for switching servers very fast.

Just change the configuration file, and all hosts will be redirected from A to B. Every single one of them will be forced to only talk to and listen from the indicated server.

Imagine now instead of the file listing one server, to list S(x) serves. Those servers could be sharing the conf.d directory or each one having his own. The first N(1) hosts would come online and ask for the configuration files from the server S(1) and when done, would start coping a new version from the server or maybe just boot and start sending important calculated/measured data. If more hosts now come online and attempt to send/receive a big amount of data, the ping in between them and the S(1) server would not pass a test, leading them to chose S(2). And this could go on for as many N(n) hosts talking with S(x) servers, where obviously x << n.

An obstacle deriving from this would be to find a way and notify the hosts already running to switch to the server with the lowest load, without them restarting, when a server has lost a number of hosts.

System directory has straight forward names with only one entry worth mentioning and that is fstab.conf. We can see that fstab appears 2 times in the list. One under the controller sub-directory with cfstab.conf and one without the “c”. Files that start with a “c” will always appear under the controller sub-directory, and aim to provide a way of configuring the system after it has been built. Say, that someone would want to change some fstab entries to all the hosts running the stateless system. Could either start remounting as rw all hosts one by one, make the changes and then remount them back to ro, choose to use a special package to do all the mounts and unmounts automatically by typing the commands once. Or could change the fstab inside the config.d directory and restart the hosts.

Again there is an obstacle deriving for this. All hosts must restart for the changes to take effect, if the last method is the case.

Note: Always cfoo.config is considered of highest priority than foo.config.


### License

Everything which will be created from this project, will be licensed 
under GPL-2
