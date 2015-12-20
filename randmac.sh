#!/bin/bash

PATHOUI=.

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
    NICETH=$(for i in {1..6} ; do echo -n ${hexchars:$(( $RANDOM % 16 )):1} ; done | sed -e 's/\(..\)/:\1/g')
    NICWLAN=$(for i in {1..6} ; do echo -n ${hexchars:$(( $RANDOM % 16 )):1} ; done | sed -e 's/\(..\)/:\1/g')

    /etc/init.d/networking stop
    ifconfig eth0 down
    ifconfig wlan0 down
    ifconfig eth0 hw ether $OUI$NICETH
    ifconfig wlan0 hw ether $OUI$NICWLAN
    ifconfig eth0 up
    ifconfig wlan0 up
    /etc/init.d/networking start
  else
    echo "File $PATHOUI/mac.txt does not exist, please update OUI first"
  fi
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
