#!/bin/bash

# UChicago Pintos VM Setup Script
#
# This script will set up Pintos on a standard UChicago CS VM image
# (currently an Ubuntu 14.04.3 image, so this script may also work
# on stock Ubuntu 14.04 images)
#
# NOTE: Before running this script, the following steps have to be 
#       carried out:
#
# 1. Change the VM's hostname by running this:
#  
#     sudo sed -i 's/CS-Vbox/pintos-vm/' /etc/hosts
#     echo "pintos-vm" | sudo tee /etc/hostname
#
# 2. Update packages:
#
#     sudo apt-get update
#     sudo apt-get dist-upgrade -u
#
#    After doing this, restart the VM.
#
# 3. Install updated VirtualBox Guest tools.
#    To do this, log into the VM, go to the VirtualBox "Devices" menu,
#    and choose "Insert Guest Additions CD image". Autorun the CD and,
#    once the installation ends, restart the VM again.
#
# 4. Run this script under the "student" account.


### DIRECTORIES ###

# Temp directory for building Pintos
BUILD_DIR="/tmp/pintos_build"

# Temp directory where we will clone the UChicago version of Pintos
PINTOS_DIR=$BUILD_DIR/pintos

# Directory where the Pintos files will be installed
TOOLS_DIR='/usr/local/pintos'


### EXTRA PACKAGES ###

sudo apt-get install texinfo qemu texlive mc


### CREATE DIRECTORIES AND DOWNLOAD BOCHS/PINTOS ###

mkdir -p ${BUILD_DIR}
sudo mkdir -p $TOOLS_DIR

cd ${BUILD_DIR}

# Download Bochs 2.2.6
wget -O ${BUILD_DIR}/bochs-2.2.6.tar.gz -c https://downloads.sourceforge.net/project/bochs/bochs/2.2.6/bochs-2.2.6.tar.gz

# Download UChicago Pintos
git clone https://github.com/uchicago-cs/pintos.git


### BUILD ###

# Build pintos utils
# Note: Will produce -Wformat-security warnings. These are expected.
cd $PINTOS_DIR/src/utils/
LDLIBS=-lm make

# Build Pintos tools
cd $BUILD_DIR
sudo $PINTOS_DIR/src/misc/build-pintos-tools $PINTOS_DIR $TOOLS_DIR $BUILD_DIR

# Create links
for BIN in $TOOLS_DIR/bin/*; do 
    sudo ln -s $BIN /usr/local/bin/`basename $BIN`
done

### TESTING ###
#
# 1. Go into $PINTOS_DIR/src/threads
#
# 2. Run "make"
#
# 3. cd into the build/ directory
#
# 4. Run "pintos run alarm-multiple".
#    This should launch a window with the following output:
#    (note: some of the numbers may be different, but the output should,
#    overall, look like this, and should not include any errors or warnings)
#
###########################################################################
#    squish-pty bochs -q
#    00000000000i[APIC?] local apic in  initializing
#    ========================================================================
#                           Bochs x86 Emulator 2.2.6
#                  Build from CVS snapshot on January 29, 2006
#    ========================================================================
#    00000000000i[     ] reading configuration from bochsrc.txt
#    00000000000e[     ] user_shortcut: old-style syntax detected
#    00000000000i[     ] installing x module as the Bochs GUI
#    00000000000i[     ] using log file bochsout.txt
#    PiLo hda1
#    Loading..........
#    Kernel command line: run alarm-single
#    Pintos booting with 4,096 kB RAM...
#    383 pages available in kernel pool.
#    383 pages available in user pool.
#    Calibrating timer...  204,600 loops/s.
#    Boot complete.
#    Executing 'alarm-single':
#    (alarm-single) begin
#    (alarm-single) Creating 5 threads to sleep 1 times each.
#    (alarm-single) Thread 0 sleeps 10 ticks each time,
#    (alarm-single) thread 1 sleeps 20 ticks each time, and so on.
#    (alarm-single) If successful, product of iteration count and
#    (alarm-single) sleep duration will appear in nondescending order.
#    (alarm-single) thread 0: duration=10, iteration=1, product=10
#    (alarm-single) thread 1: duration=20, iteration=1, product=20
#    (alarm-single) thread 2: duration=30, iteration=1, product=30
#    (alarm-single) thread 3: duration=40, iteration=1, product=40
#    (alarm-single) thread 4: duration=50, iteration=1, product=50
#    (alarm-single) end
#    Execution of 'alarm-single' complete.
###########################################################################
#
#    Press the "Power" button to close the test.
#
# 5. Run "pintos --qemu -- run alarm-single". The output should be similar to
#    the above output, except the lines above "PiLo hda1" will be QEMU-specific.
#    The test will also run more slowly; this is normal.


### TESTING (INSTRUCTORS ONLY) ###
#
# Download the reference solution in $BUILD_DIR. cd into tests/ and run:
# 
#    make p1
#    make p2
#    make p3
#    make p4
#
# Each of these should run without error, and report 100% score on the tests.
# 
# To be on the safe side, also run "make check". This runs all the tests,
# but also builds the public versions as well. It's harder to see the
# test scores, but if "make check" runs without any errors, then the VM
# setup is probably pretty solid. 


### PREPARING GOLDEN VM IMAGE ###
#
# Run the following commands to clean up the VM before creating the
# golden image that will be distributed to students
#
#   rm -rf $BUILD_DIR
#   sudo rm -rf ~/.vim ~/.emacs.d ~/.gitconfig ~/.mozilla ~/.ssh/*key* /root/bin/ /root/files/ /root/.bash_history
#   sudo service rsyslog stop
#   sudo logrotate -f /etc/logrotate.conf
#   sudo rm -f /var/log/*-???????? /var/log/*.gz
#   cat /dev/null | sudo tee /var/log/wtmp
#   cat /dev/null | sudo tee /var/log/lastlog
#   rm .bash_history
#   unset HISTFILE
#
# Note: If using the CS 121 VM as a starting point, edit the ~/.bashrc to remove the CS121-specific setup
#
# At this point, shut down the VM, and export a new Appliance from VirtualBox



