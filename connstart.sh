MEYE_REALPATH="$(dirname $(readlink -f $0))"
source "$MEYE_REALPATH""/./config.conf"

##Apply NGROK Authorisation Token to connect.yml file## 
if ! grep -wq "authtoken: "$NGROK_TOKEN $MEYE_REALPATH/connect.yml; then sed -i "/authtoken: /c\authtoken: "$NGROK_TOKEN $MEYE_REALPATH/connect.yml; fi;

##Set a valid NGROK connection region - will help reduce connection latency: Will run at first run and after changes##
if [[ "${NGROK_TUNNEL_REGIONS[@]}" =~ $NGROK_REGION ]]; then if ! grep -wq "region: "$NGROK_REGION $MEYE_REALPATH/connect.yml; then sed -i "/region: /c\region: "$NGROK_REGION $MEYE_REALPATH/connect.yml; fi; else sed -i "/region: /c\region: us" $MEYE_REALPATH/connect.yml; fi

##Create a log entry for this tunnel event##
echo "CONNECTION_MEYECONNECT: `date -u`" >> $MEYE_REALPATH/$LOG_NAME;
"$MEYE_REALPATH"/./ngrok start -config=$MEYE_REALPATH/connect.yml --all >> $MEYE_REALPATH/$LOG_NAME &

##Wait for N (default is 10) seconds to allow NGROK to create a tunnel##
sleep $CONN_WAIT

###Send a Push with our NGROK tunnel URL if notifications enabled###
if [ "${USE_PS_NOT^^}" == "Y"  ]; then
/usr/bin/python $MEYE_REALPATH/sendps.py   
fi

###Send an email with our NGROK tunnel URL if notifications enabled###
if [ "${USE_EMAIL_NOT^^}" == "Y"  ]; then
/usr/bin/python $MEYE_REALPATH/sendmail.py
fi
