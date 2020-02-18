source ./config.conf

##Apply NGROK Authorisation Token to connect.yml file## 
if ! grep -wq "authtoken: "$NGROK_TOKEN connect.yml; then sed -i "/authtoken: /c\authtoken: "$NGROK_TOKEN connect.yml; fi;

##Set a valid NGROK connection region - will help reduce connection latency: Will run at first run and after changes##
if [[ " ${NGROK_TUNNEL_REGIONS[@]} " =~ $NGROK_REGION ]]; then; if ! grep -wq "region: "$NGROK_REGION connect.yml; then sed -i "/region: /c\region: "$NGROK_REGION connect.yml; fi; else; sed -i "/region: /c\region: us" connect.yml; fi;

##Create a log entry for this tunnel event##
echo "`date -u`" >> $LOG_NAME;
./ngrok start -config=connect.yml --all >> LOG_NAME &

##Wait for N (default is 10) seconds to allow NGROK to create a tunnel##
sleep $CONN_WAIT

###Get the NGROK Public URL of our tunnel and send it to us using Pushsafer (You will require a Pushsafer (www.pushsafer.com) account to use this functionality)###
curl -s http://localhost:4040/api/tunnels/meyeconnect | python -c 'import json,subprocess,sys;obj=json.load(sys.stdin);ngrokurl=obj["'public_url'"]; subprocess.call(["curl", "-s", "--data-urlencode","k='$PS_KEY'","-d","m='"$PS_MSG"'","-d","u="+ngrokurl,"-d","p='$PS_PRIORITY'","-d","s='$PS_SND'","-d","i='$PS_ICON'","-d","c='$PS_ICON_HEX'","-d","t='"$PS_TITLE"'","-d","ut='"$PS_URL_TITLE"'", "https://www.pushsafer.com/api"], stdout=open("/dev/null", "wb"))' &
