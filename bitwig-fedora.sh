#!/bin/bash
#===================================================================================
#
# FILE: fedora-bitwig.sh
#
# USAGE: fedora-bitwig.sh [-i] [-h]
#
# DESCRIPTION: This script automates the Bitwig Studio installation process on
# Fedora 26 distribution.
# The default starting directory is the current directory.
# Don’t descend directories on other filesystems.
#
# OPTIONS: see function ’usage’ below
# REQUIREMENTS: Fedora 26 Workstation, Bitwig Studio 2.1.3
# NOTES: ---
#===================================================================================

ROOT_UID=0
E_NOTROOT=87
DEFAULT_URL="https://downloads.bitwig.com/stable/2.1.3/bitwig-studio-2.1.3.deb"
DEFAULT_FILENAME="bitwig-studio-2.1.3.deb"
SHA256="8b6a5abfe0f63aba60a871676e7369e186bc26edb1d510b4ff3c50afdae18e2e"
OS_VERSION="Fedora release 26 (Twenty Six)"

#=== FUNCTION ================================================================
# NAME: usage
# DESCRIPTION: Display usage information for this script.
# PARAMETER 1: Install
#===============================================================================
function usage()
{
  printf " usage: $0 <option> \n \n"
  printf " options:\n"
  printf "  -i \t Installs Bitwig Studio\n"
  printf "  -h \t Show this menu \n"
}


#=== FUNCTION ================================================================
# NAME: download_bitwig
# DESCRIPTION: Download the correct version of Bitwig Studio for the installation.
#===============================================================================
function download_bitwig()
{
  if [ -f $DEFAULT_FILENAME ] ; then
    echo "Package $DEFAULT_FILENAME already exists."
  else
    echo "Package $DEFAULT_FILENAME does not exist. Initializing the download..."
    wget $DEFAULT_URL
  fi

  echo "Verifying the package checksum. Please wait..."
  if [ "$(sha256sum $DEFAULT_FILENAME | awk {'print $1'})" != "$SHA256" ] ; then
    echo "The checksum doesn't match. Please download the package again."
    exit 1
  else
    echo "Package checksum successfully validated."
  fi
}


#=== FUNCTION ================================================================
# NAME: unpack_bitwig
# DESCRIPTION: Unpack deb package. Copy files to the correct folders.
#===============================================================================
function unpack_bitwig()
{
  echo "Unpacking $DEFAULT_FILENAME . Please Wait..."
  dpkg-deb -x $DEFAULT_FILENAME /
}


#=== FUNCTION ================================================================
# NAME: install_dependencies
# DESCRIPTION: Install dependencies for the correct execution of this script.
#===============================================================================
function install_dependencies()
{
  echo "Installing dependencies. Please Wait..."
  dnf -y install libbsd bzip2-libs dpkg
}


#=== FUNCTION ================================================================
# NAME: create_symbolic_links
# DESCRIPTION: Create symbolic links for library files, to assure the right
# fuction of Bitwig Studio.
#===============================================================================
function create_symbolic_links()
{
  echo "Creating symbolic links."
  ln -s /usr/lib64/libbz2.so.1 /usr/lib64/libbz2.so.1.0
}


#=== FUNCTION ================================================================
# NAME: install
# DESCRIPTION: Set of fuctions to install Bitwig Studio
#===============================================================================
function install()
{
  download_bitwig
  install_dependencies
  create_symbolic_links
  unpack_bitwig
}


#=== MAIN ====================================================================
if [ "$(cat /etc/fedora-release)" != "$OS_VERSION" ] ; then
  echo "Wrong OS version. Make sure you run the script in - $OS_VERSION -."
  exit 1
fi

if [ "$UID" -ne "$ROOT_UID" ]; then
  echo "You must be root to run this script."
  exit $E_NOTROOT
fi

if [ $# -eq 0 ] ; then
  usage
  exit 1
fi

option=$1

case ${option} in
    "-h")
        usage
        ;;
    "-i")
        install
        ;;
    *)
        usage
        exit 1
esac

echo "Installation Complete. You can execute Bitwig Studio from the Applications menu in gnome"
echo "(Sound and Video section), or running: bitwig-studio in terminal."

exit 0
