 #/bin/sh

 sudo curl -so /etc/apt/trusted.gpg.d/oxen.gpg https://deb.oxen.io/pub.gpg

  echo "deb https://deb.oxen.io $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/oxen.list

  sudo apt install ca-certificates

  sudo apt update

  sudo apt install python3-{oxenmq,oxenc,pyonionreq,coloredlogs,uwsgidecorators,flask,cryptography,nacl,pil,protobuf,openssl,qrencode,better-profanity,sqlalchemy,sqlalchemy-utils} uwsgi-plugin-python3


  sudo apt install python3 python3-flask python3-coloredlogs python3-requests python3-pip

  pip3 install psycopg psycopg_pool  # Or as above, once these enter Debian/Ubuntu

  sudo rm -rf /usr/lib/python3/dist-packages/pyonionreq.cpython-38-x86_64-linux-gnu.so


  cd contrib
  sudo cp pyonionreq.cpython-38-x86_64-linux-gnu.so /usr/lib/python3/dist-packages/pyonionreq.cpython-38-x86_64-linux-gnu.so

  sudo cp liboxenmq.so.1.2.11 /usr/lib/x86_64-linux-gnu/liboxenmq.so.1.2.11