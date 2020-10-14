MEYE_PATH="meyeconnect/"
MEYE_UIFILE="/data/etc/userinit.sh"
MEYE_INSTXT="INSTALL_MEYECONNECT: "
MEYE_TS="pool.ntp.org"
TERMSETUP_TXT="Terminating MeyeConnect Setup!"
CONTSETUP_TXT="Proceeding with MeyeConnect Setup!"
BNR_DESC_SLEEP=1

###MEYECONNECT FILE MANIFEST###
MEYEF0=("
https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-arm.zip
4ac946805aa18743749c0981d8b18011
500
")
MEYEF1=("
https://s3.eu-central-1.wasabisys.com/ds4a-public/meyeconnect/latest/config.conf
f82053501a72d9b21f171d9a84c62512
600
")
MEYEF2=("
https://s3.eu-central-1.wasabisys.com/ds4a-public/meyeconnect/latest/connect.yml
2defd5ebe7ad68ddeb331dd5c14162cd
600
")
MEYEF3=("
https://s3.eu-central-1.wasabisys.com/ds4a-public/meyeconnect/latest/connstart.sh
f382831a1cc9fed666ab837ed813bb7c
500
")
MEYEF4=("
https://s3.eu-central-1.wasabisys.com/ds4a-public/meyeconnect/latest/sendmail.ini
026c938937d390577d2a52cf0a1251bf
600
")
MEYEF5=("
https://s3.eu-central-1.wasabisys.com/ds4a-public/meyeconnect/latest/sendmail.py
efd0cacd08d1136cacf100431085cb77
500
")
MEYEF6=("
https://s3.eu-central-1.wasabisys.com/ds4a-public/meyeconnect/latest/sendps.ini
a3a891ec9c80e2a30dedaa636409b69d
600
")
MEYEF7=("
https://s3.eu-central-1.wasabisys.com/ds4a-public/meyeconnect/latest/sendps.py
4b16d3353aadd9323d771786c9aeb412
500
")
MEYEF8=("
https://s3.eu-central-1.wasabisys.com/ds4a-public/meyeconnect/latest/connchk.py
cddb52b1b58861a4a9017fcaef7154d8
500
")

MEYEFILEARR=(
[0]=$MEYEF0
[1]=$MEYEF1
[2]=$MEYEF2
[3]=$MEYEF3
[4]=$MEYEF4
[5]=$MEYEF5
[6]=$MEYEF6
[7]=$MEYEF7
[8]=$MEYEF8
)

###MEYE INSTALLATION FUNCTIONS###

function chk_os(){
ALLOWED_FF=("Raspberry")
ff=($(tr -d '\0' </proc/device-tree/model))
ffpass=FALSE

for t in ${ALLOWED_FF[@]}; do
 if [[ ${ff} =~ ${t} ]]; then
  ffpass=TRUE
 fi
done
if [ $ffpass == "FALSE" ]; then
  msg_bin_conf "MeyeConnect MAY not work with this Board Factor. Do you want to proceed? Y/N?" "\n$TERMSETUP_TXT" "\n$CONTSETUP_TXT" " - Unsupported Board Factor"
  installevent_log "$MEYE_INSTXT""N - Form Factor FAILED! - $ff"
else
  installevent_log "$MEYE_INSTXT""Y - Form Factor PASSED! - $(tr -d '\0' </proc/device-tree/model)"
fi
}

#text-filename, text-filemd5sum
function chk_md5sum(){
fmd5="$(md5sum $MEYE_PATH"$1" | cut -d ' ' -f 1)"
 if ! [ "$fmd5" = $2 ] ; then
  eventlog_txt="$MEYE_INSTXT""N - MD5 Checksum FAILED! - $1 - Got: $fmd5 - Expected: $2"
  installevent_log "$eventlog_txt"
  echo -e "\n"$eventlog_txt
  echo -e "\n"$TERMSETUP_TXT  
  exit 0
 else
  installevent_log "$MEYE_INSTXT""Y - MD5 Checksum PASSED! - $1 - $fmd5"
 fi
}

#element-number, text-number
function drw_bnr(){
 bnr_txt=("MeyeConnect for MotionEyeOS by DS4A" "  Raspberry Pi Compatible Version  " "https://github.com/ds4a/meyeconnect")
 case "$1" in
  1)  echo "**************************************************************"
      ;;
  2)  echo  "|           ""${bnr_txt[$2]}""              |"
      ;;
 esac
}

##array##
function get_meyefiles() {
for i in "$@}"
 do
  newfilearr=(${i})
   while true; do
     (cd $MEYE_PATH && echo -e "Getting: ${newfilearr[0]##*/}" && curl -# -O --fail ${newfilearr[0]}) && break ||
     installevent_log "$MEYE_INSTXT""N - MeyeConnect File Download FAILED! - ${newfilearr[0]##*/} - ${newfilearr[0]}"
     echo -e "\nDownload failed for : ${newfilearr[0]} - retrying...\n"
   done
   installevent_log "$MEYE_INSTXT""Y - MeyeConnect File Download SUCCEEDED! - ${newfilearr[0]##*/} - ${newfilearr[0]}"
   chk_md5sum "${newfilearr[0]##*/}" "${newfilearr[1]##*/}"
   chmod ${newfilearr[2]} "$MEYE_PATH${newfilearr[0]##*/}"
    if [ $? -eq 0 ]; then installevent_log "$MEYE_INSTXT""Y - CHMOD - ${newfilearr[0]##*/} - ${newfilearr[2]}";else installevent_log "$MEYE_INSTXT""N - CHMOD - ${newfilearr[0]##*/} - ${newfilearr[2]}";fi
 done
}

#text-string
function installevent_log(){
        echo $1 >> /data/$MEYE_PATH/meyeconnect.log
}

#message-text, terminate-text, confirm-text, log-text, action[0-default, 1-continue, 2-repeat], read-options
function msg_bin_conf(){
echo -e "\n"
read $6 "$1" msgresp
case "$5" in
 0) a=$msgresp ;;
 1) a="Y" ;;
 2) a="0" ;;
 *) a="0" ;;
esac
if [[ ${a^^} == "N" ]];then
  echo -e ""$2"";installevent_log "$MEYE_INSTXT""${a^^}""$4";exit 0
 elif [[ ${a^^} == "Y" ]];then
  installevent_log "$MEYE_INSTXT""${a^^}""$4";echo -e ""$3""
 else msg_bin_conf "\n${1}" "${2}" "${3}" "${4}" "${5}" "${6}"
fi;
}

function chk_runasroot(){
    if [[ $EUID -ne 0 ]]; then
	installevent_log "$MEYE_INSTXT""N - Run as ROOT"
        echo "Error:This script must be run as root!" 1>&2
        exit 1
    else
	installevent_log "$MEYE_INSTXT""Y - Run as ROOT"
    fi
}

function run_curl(){
    while true; do
      (cd $MEYE_PATH && curl -# -O --fail $1) && break ||
      installevent_log "$MEYE_INSTXT""N - MeyeConnect File Download FAILED! - $2 - $1"
      echo -e "\nDownload failed for : $2 - retrying...\n"
    done
    installevent_log "$MEYE_INSTXT""Y - MeyeConnect File Download SUCCEEDED! - $2 - $1"
}

#key-string, data-string, file-string action[0=replace, 1=append]
update_file(){
F_PATH=${MEYE_PATH}
F_KEY="$1"
F_NAME="$3"
F_DATA="$2"
case "$4" in
 0) if ! grep -wq "$F_KEY$F_DATA" "$F_PATH$F_NAME"; then sed -i "/$F_KEY/c\\$F_KEY"$F_DATA "$F_PATH$F_NAME"; fi; installevent_log "INSTALL_MEYECONNECT: Y - $F_KEY${F_DATA:0:6}....." ;;
 1) echo "File Update FAILED!" ;;
esac
}

##############################################################################################
clear
echo ""
drw_bnr "1"
drw_bnr "2" "0"
drw_bnr "1"
drw_bnr "2" "1"
drw_bnr "1"
drw_bnr "2" "2"
drw_bnr "1"
echo ""
sleep 1

echo -e "\nMeyeConnect utilises Ngrok, a fully self contained binary, that
does not require any external dependencies to create a secure,
robust and reliable internet accessible tunnel.\n"
sleep $BNR_DESC_SLEEP

echo -e "\nThis means you can gain access to your own MotionEyeOS network
connected installation from almost anywhere (internet access is
required by your MotionEyeOS installation / network).\n"
sleep $BNR_DESC_SLEEP

echo -e "\nCGNAT (Carrier Grade Network Address Translation) which is used
by mobile and other ISPs to conserve IPv4 static and dynamic IP's
has meant either installing and configuring a VPN or other time
consuming and/or complicated solutions to achieve access to your
MotionEyeOS controlled cameras.\n"
sleep $BNR_DESC_SLEEP

echo -e "\nMeyeConnect using Ngrok (and PushSafer notifications if choosen)
makes the process of creating a secure, reliable and uncomplicated
connection to your MotionEyeOS installation, relative childsplay.\n"
sleep $BNR_DESC_SLEEP

echo -e "\nCurrenly MeyeConnect has only been tested with MotionEyeOS on
Raspberry Pi, but you're welcome to see what mileage you get with
other boards...."
sleep $BNR_DESC_SLEEP

echo ""
    read -sn1 -p "Do you want to Setup MeyeConnect? [Y/N]" setupmeyeconnect
    # Continue or Terminate
    if [ "${setupmeyeconnect^^}" = "Y" ]; then
     echo -e "\n\n$CONTSETUP_TXT"
    else
     echo -e "\n\n$TERMSETUP_TXT"
     exit 0
    fi

if ( mkdir -p $MEYE_PATH/ ) ; then
  installevent_log "START_INSTALLATION: `date -u`"
  installevent_log "$MEYE_INSTXT""Y - Create meyeconnect directory / directory already exists."
 else
  echo "\nUnable to create MeyeConnect installation directory!"
  exit 1
fi

chk_runasroot
chk_os

sleep $BNR_DESC_SLEEP
echo -e "\nDownloading and Checking MeyeConnect files......"
get_meyefiles "${MEYEFILEARR[@]}"
echo -e "\nUnpacking Ngrok......"
gunzip -S .zip -d -c $MEYE_PATH"ngrok-stable-linux-arm.zip" > $MEYE_PATH"ngrok"
rm $MEYE_PATH"ngrok-stable-linux-arm.zip"
chmod 500 "$MEYE_PATH""ngrok"
if [ $? -eq 0 ]; then installevent_log "$MEYE_INSTXT""Y - CHMOD - ngrok - 500";else installevent_log "$MEYE_INSTXT""N - CHMOD - ngrok - 500";fi

###NGROK###
msg_bin_conf "Have you signed up for a FREE or paid Ngrok (www.ngrok.com) account yet? Y/N" "\n$TERMSETUP_TXT" "\n\n$CONTSETUP_TXT" " - Confirm Ngrok account" "0" "-sn1 -p"
sleep 1
######GET NGROK AUTHTOKEN AND UPDATE CONNECT FILE######
while true; do
    echo -e "\n"
    read -p "Type (or copy and paste) your Ngrok AuthToken here and hit [ENTER]:" ngrokauthprovide
    installevent_log "$MEYE_INSTXT""Y - Provided Ngrok AuthToken"
    ngrokauthtoken=${ngrokauthprovide}
    clear
    echo -e "\n"
    read -sn1 -p "Is - $ngrokauthtoken  - the correct Ngrok AuthToken? [Y/N]" ngroktokenconf
    installevent_log "$MEYE_INSTXT""${ngroktokenconf^^} - Confirmation of Ngrok AuthToken"
    # Exit the loop if token correct
    if [ "${ngroktokenconf^^}" = "Y" ] ; then
        break
    else
       continue
    fi
done
	update_file "authtoken: " "${ngrokauthtoken}" "connect.yml" "0"
	update_file "NGROK_TOKEN=" "\"${ngrokauthtoken}"\" "config.conf" "0"
sleep 1
echo -e "\n\nYou can now select a Ngrok tunnel region to use, this reduces connection latency.
The default region for MeyeConnect is EU-(Europe), just hit [ENTER] to accept.
\nAlternatively enter the NGROK 2 character code for the region you want to use.
You can find all available regions at https://ngrok.com/docs#global-locations."
sleep 1
while true; do
    echo -e "\n"
    read -p "Enter a Ngrok tunnel region. Default is EU press [ENTER] to accept:" ngrokregionprovide
    source $MEYE_PATH"config.conf" ${NGROK_TUNNEL_REGIONS[@]}

    if [[ " ${NGROK_TUNNEL_REGIONS[@]} " =~ $ngrokregionprovide || $ngrokregionprovide == $'\x0a' ]]; then
	if [[ $ngrokregionprovide == ${x0a} ]] ; then
	 ngrokregionprovide="eu"
	fi
	update_file "region: " "${ngrokregionprovide}" "connect.yml" "0"
        update_file "NGROK_REGION=" "\"${ngrokregionprovide}"\" "config.conf" "0"
       break
    else
       installevent_log "$MEYE_INSTXT""N - Invalid Ngrok region - $ngrokregionprovide"
       continue
    fi
done

###PUSHSAFER###
msg_bin_conf "If you have a PushSafer account, do you want to use it to get notifications about your MotionEyeOS endpoint? [Y/N]" "\n$TERMSETUP_TXT" "\n\n$CONTSETUP_TXT" " - Confirm PushSafer account" "1" "-sn1 -p"
sleep 1
######GET PUSHSAFER AUTHTOKEN AND UPDATE CONFIG FILE######
if [ "${msgresp^^}" = "Y" ]; then
while true; do
    echo -e "\n\n"
    read -p "Type (or copy and paste) your PushSafer AuthToken here and hit [ENTER]:" pushsaferauthprovide
    installevent_log "$MEYE_INSTXT""Y - Provide PushSafer AuthToken"
    pushsaferauthtoken=${pushsaferauthprovide}
    clear
    echo -e "\n"
    read -sn1 -p "Is - $pushsaferauthprovide  - the correct PushSafer AuthToken? [Y/N]" pushsafertokenconf
    installevent_log "$MEYE_INSTXT${pushsafertokenconf^^} - Confirmation of PushSafer AuthToken"
    # Exit the loop if token correct
    if [ "${pushsafertokenconf^^}" = "Y" ] ; then
     update_file "USE_PS_NOT=" "\"Y"\" "config.conf" "0"
     update_file "psapikey = " "${pushsaferauthtoken}" "sendps.ini" "0"
     break
    else
       continue
    fi
done
fi

echo -e "\n"
read -sn1 -p "Would you like to receive email notifications about your MotionEyeOS endpoint? [Y/N]" emailnotifs

if [ "${emailnotifs^^}" = "Y" ];then

######GET EMAIL INFO AND UPDATE SENDMAIL FILE######
while true; do
    echo -e "\n"
    read -p "Type a 'FROM:' email address and hit [ENTER]:" efromprovide
    echo -e "\n"
    read -p "Type a 'TO:' email address and hit [ENTER]:" etoprovide
    echo -e "\n"
    read -p "Type a 'MAILSERVER FQDN' and hit [ENTER]:" esvrprovide
    echo -e "\n"
    read -p "Type a 'MAILSERVER PORT' to use and hit [ENTER]:" esvrportprovide
    echo -e "\n"
    read -p "Type a 'MAILSERVER USERNAME' and hit [ENTER]:" esvruserprovide
    echo -e "\n"
    read -p "Type a 'MAILSERVER PASSWORD' and hit [ENTER]:" esvrpassprovide
    echo -e "\n"
    read -sn1 -p "Are all of the above entries correct? [Y/N]" econfresp
clear
    if [ "${econfresp^^}" = "Y" ];then
     installevent_log "$MEYE_INSTXT""${econfresp^^} - Mailserver Setup - "$efromprovide","$etoprovide","$esvrprovide","$esvrportprovide","$esvruserprovide
     update_file "USE_EMAIL_NOT=" "\"Y"\" "config.conf" "0"
     update_file "efrom = " "$efromprovide" "sendmail.ini" "0"
     update_file "eto = " "$etoprovide" "sendmail.ini" "0"
     update_file "esvr = " "$esvrprovide" "sendmail.ini" "0"
     update_file "esvrport = " "$esvrportprovide" "sendmail.ini" "0"
     update_file "esvruser = " "$esvruserprovide" "sendmail.ini" "0"
     update_file "esvrpass = " "$esvrpassprovide" "sendmail.ini" "0"
     break
    else
     continue
    fi
done
fi

######ADD MEYECONNECT SCRIPT TO THE MOTIONEYEOS USER STARTUP SCRIPT######
touch $MEYE_UIFILE
if ! grep -wq "/data/"$MEYE_PATH"connstart.sh >> /data/"$MEYE_PATH"meyeconnect.log 2>&1 &" "/data/etc/userinit.sh"; then
 echo "/data/"$MEYE_PATH"connstart.sh >> /data/"$MEYE_PATH"meyeconnect.log 2>&1 &" >> $MEYE_UIFILE
 installevent_log "$MEYE_INSTXT""Y - Update userinit.sh - Entry Added!"
else
 installevent_log "$MEYE_INSTXT""N - Update userinit.sh - Entry already exists!"
fi

######ADD NGROK CONNECTIVITY CHECK TO CRON SCHEDULE - CHECKS EVERY 10 MINUTES#######
msg_bin_conf "Add connection checking to cron schedule? [Y/N]" "\nOK, skipping adding connection checking to cron schedule" "\n\nAdding cron schedule!" " - Add NGROK Connection Check Cron!" "1" "-sn1 -p "
if [ "${msgresp^^}" = "Y" ];then crontab -l | { cat; echo "*/10 * * * *  /usr/bin/python /data/"$MEYE_PATH"connchk.py >/dev/null 2>&1"; } | crontab - ; fi

msg_bin_conf "Reboot MotionEyeOS to complete setup and obtain endpoint? [Y/N]" "\n$TERMSETUP_TXT" "\n\nRebooting!" " - Confirm System Reboot!" "0" "-sn1 -p "
if [ "${msgresp^^}" = "Y" ];then reboot; fi
