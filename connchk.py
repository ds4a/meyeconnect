import os, sys, json, urllib, datetime
try:
# python 3
        from urllib.parse import urlencode
except ImportError:
# python 2
        from urllib import urlencode
from StringIO import StringIO

# python 2.x
from ConfigParser import SafeConfigParser
config = SafeConfigParser()
# python 3.x
#from configparser import ConfigParser
#config = ConfigParser()
trupath = os.path.dirname(os.path.abspath(__file__))
config.read(''+trupath+'/sendps.ini')

#Get the public ngrok url of our tunnel or get ready to re-initialise it
url = config.get('pssend','pslocalurl')
try:
        response = urllib.urlopen(url)
        obj=json.load(response)
        tunnelurl=obj['public_url']
        connresp = response.getcode()
except IOError:
        connresp = 0
        pass

#Write a log entry
conntestdatetime = datetime.datetime.today().strftime ('%d-%m-%Y - %H:%M:%S')
file = open(''+trupath+'/meyeconnect.log','a')

if connresp == 200:
        file.write('NOTIFICATION_MEYECONNECT: Y - NGROK Connection Active - ' + tunnelurl + ' - ' + str(conntestdatetime) + '\n')
else:
        file.write('NOTIFICATION_MEYECONNECT: Y - NGROK Connection Failed - ' + str(conntestdatetime) + '\n')
        #Attempt to reinitialise a Ngrok tunnel.
        import subprocess
        subprocess.call(trupath+'/connstart.sh', shell=True)
        file.write('NOTIFICATION_MEYECONNECT: Y - NGROK Attempted Re-Initialisation - ' + str(conntestdatetime) + '\n')
file.close()

