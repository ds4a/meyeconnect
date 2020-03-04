import os, sys, json, urllib, pycurl
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

#Get the public ngrok url of our tunnel
url = config.get('pssend','pslocalurl')
response = urllib.urlopen(url)
obj=json.load(response)
tunnelurl=obj['public_url']

apiURL = config.get('pssend','psapiurl')
data = {"k": config.get('pssend','psapikey'), "m": config.get('pssend','psmsg'),"p": config.get('pssend','pspriority'),"s": config.get('pssend','pssound'),"i": config.get('pssend','psicon'),"c": config.get('pssend','psiconhex'),"t": config.get('pssend','pstitle'),"ut": config.get('pssend','psurltitle'),"u": tunnelurl}
postdata = urllib.urlencode(data)
c = pycurl.Curl()
c.setopt(c.URL, apiURL)
c.setopt(c.POSTFIELDS,postdata)
c.setopt(c.VERBOSE, 0)
cresp = StringIO()
c.setopt(c.WRITEDATA, cresp)
c.perform()
c.close()

#Write a log entry
file = open(''+trupath+'/meyeconnect.log','a')
file.write('NOTIFICATION_MEYECONNECT: Y - Push Sent - '+cresp.getvalue()+'\n')
file.close()
