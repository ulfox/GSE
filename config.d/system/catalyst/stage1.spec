# STAGE1.SPEC FILE

# Subarch instucts the catalyst about what kind of architecture built should be enabled
subarch: amd64

# Target instructs catalyst about the stage of the process
target: stage1

# This is the version stamp that will be given to all successfully built stages.
# Example: latest will give a stage{1,2,3}-latest.tar.bz2
version_stamp: latest

# This is the directory under $storedir/builds, where the built stages will be saved
rel_type: default

# The profile instructs catalyst about which profile is going to be used, which in turn
# implies which packages will be built at the gives stage and which flags will be used.
# It is almost mandatory for the subarch to match the .../linux/<arch>/ entry
profile: default/linux/amd64/13.0

# This is the prefix of the portage snapshot that is going to be used, under $storedir/snapshots
# Example: latest means that catalyst will search for portage-latest.tar.bz2 snapshot.
snapshot: latest

# This is the subpath under $storedir/builds/ that catalyst will use for the seed tarball
# Example: foo/bar means that catalyst will search under $storedir/builds/foo
# for the seed tarball bar.tar.bz2
source_subpath: default/stage3-latest

# Distcc hosts tell catalyst which hosts will be participating in the building process.
# This option alone does nothing. Distcc must be enabled on all hosts, started on the server
# and properly configured to allow connections between them.
# Note: You should update the MAKEOPTS="-jN" in the catalystrc if you plan to use distcc.
# A sane value for N would be the sum of host's cores and server's multiplied by two, but this
# is very general. For expert configurations about the distcc hosts /X value, -jN value and more
# advanced features, please check the Gentoo wiki, since it has an amazing collection of information
# related with this.
# Distcc_hosts: 192.168.1.0/24

# The following options should give an idea just by reading them, however if you are unsure please, check
# the documentation area under the documentation submenu of this project or under 
# /usr/share/docs/catalyst-<version>/examples
update_seed: yes
update_seed_command: --update --deep @world

