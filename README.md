<b>MEYECONNECT</b>

MeyeConnect utilises Ngrok, a fully self contained binary, that
does not require any external dependencies to create a secure,
robust and reliable internet accessible tunnel.

This means you can gain access to your own MotionEyeOS network
connected installation from almost anywhere (internet access is
required by your MotionEyeOS installation / network).

CGNAT (Carrier Grade Network Address Translation) which is used
by mobile and other ISPs to conserve IPv4 static and dynamic IP's
has meant either installing and configuring a VPN or other time
consuming and/or complicated solutions to achieve access to your
MotionEyeOS controlled cameras.

MeyeConnect using Ngrok makes the process of creating a secure,
reliable and uncomplicated connection to your MotionEyeOS installation,
relative childsplay.

Having created a Ngrok tunnel you can choose to get notifications of the
public Ngrok URL via PushSafer push notifications direct to your mobile phone
or alternatively / in addition via email.

You also have the option of setting up connection checking to ensure you
always have access to your MotionEyeOS RPI cameras should your Ngrok tunnel
public URL changes or if your tunnel terminates.

Currenly MeyeConnect has only been tested with MotionEyeOS on
Raspberry Pi, but you're welcome to see what mileage you get with
other boards....

<b>PRE-INSTALLATION</b>

NGROK: You will require an account/plan with Ngrok and be able to obtain an AuthToken from your account.
(For most people the Free Ngrok account will be adequate)

PUSHSAFER: If you want to receive push notifications with a link to your Ngrok public URL for your tunnel
you will require a PushSafer account and be able to obtain an AuthToken from your account (you get 50 api call notifications included with a new account (as at the time of writing) and additional api calls can be purchased from 0.99 Euro for 1000 api calls)

EMAIL: If you also want to receive email push notifications with a link to your Ngrok public URL for your tunnel
you will require a working email account and know the account information such as email adrress, username, password, server port, server FQDN. 

<b>INSTALLATION</b>

1.) Login in to your Raspberry Pi (ssh admin@<YOUR_RPI_LOCALIP_ADDRESS>)   
2.) #cd /data/   
3.) # curl -O https://s3.eu-central-1.wasabisys.com/ds4a-public/meyeconnect/latest/install.sh   
4.) # chmod 500 install.sh   
5.) # ./install.sh   
