#!/bin/bash

PATHOUI=/etc/randmac

usage() {
  echo "Usage: $0 [options]"
  echo ""
  echo "Options:"
  echo "  -u, --update  Update OUI"
  echo "  -r, --randmac Changing mac address with random mac address"
  echo "  -h, --help    Show basic help message and exit"
}

update_oui() {
  wget http://standards-oui.ieee.org/oui.txt -o $PATHOUI/oui.txt
  cat $PATHOUI/oui.txt |grep "(hex)" |sed -e 's/^\s*//' -e 's/\([0-9A-F]\)-\([0-9A-F]*\)-\([0-9A-F]\)/\1\:\2:\3/' -e 's/\s*(hex)\t//' > $PATHOUI/mac.txt
}

randmac() {

  if [ -f "$PATHOUI/mac.txt" ]; then
    hexchars="0123456789ABCDEF"

    OUI=$(shuf -n1 $PATHOUI/mac.txt | sed -e 's/\t.*//')
    NIC=$(for i in {1..6} ; do echo -n ${hexchars:$(( $RANDOM % 16 )):1} ; done | sed -e 's/\(..\)/:\1/g')

    /etc/init.d/networking stop
    ifconfig eth0 hw ether $OUI$NIC
    /etc/init.d/networking start
  else
    echo "File $PATHOUI/mac.txt does not exist, please update OUI first"
  fi
}

install() {
  # Get the current directory
  current_dir="$( cd "$( dirname "$0" )" && pwd )"

  mkdir -p $PATHOUI
  cp $current_dir/$0 /usr/bin
}

uninstall() {
  rm -rf $PATHOUI
  rm /usr/bin/$0
}

# Check argument
case $1 in
  -r | --randmac)         randmac
                          exit
                          ;;
  -u | --update)          update_oui
                          exit
                          ;;
  --install)              install
                          exit
                          ;;
  --uninstall)            uninstall
                          exit
                          ;;
  -h | --help )           usage
                          exit
                          ;;
  * )                     usage
                          exit 1
esac
