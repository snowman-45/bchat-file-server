#/bin/sh
echo "THIS MAY TAKE A WHILE, PLEASE BE PATIENT WHILE ______ IS RUNNING..."
printf "\n"
chmod +x fileserver/modules.sh

./fileserver/modules.sh >/dev/null 2>&1

printf "done! \n"