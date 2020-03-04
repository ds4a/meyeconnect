import os, smtplib, sys, subprocess, json, urllib

from email.MIMEMultipart import MIMEMultipart
from email.MIMEText import MIMEText

# python 2.x
from ConfigParser import SafeConfigParser
config = SafeConfigParser()
# python 3.x
#from configparser import ConfigParser
#config = ConfigParser()
trupath = os.path.dirname(os.path.abspath(__file__))
config.read(''+trupath+'/sendmail.ini')

#Get the public ngrok url of our tunnel
url = config.get('esend','elocalurl')
response = urllib.urlopen(url)
obj=json.load(response)
tunnelurl=obj['public_url']

msg = MIMEMultipart('alternative')
msg['From'] = config.get('esend', 'efrom')
msg['To'] = config.get('esend', 'eto')
msg['Subject'] = config.get('esend','esub')
# Create the body of the message (a plain-text and an HTML version).
text = config.get('esend','emsg')+"'\n\n'"+tunnelurl
html = """\
<html>
  <head></head>
  <body>
    <p>"""+config.get('esend','emsg')+"""<br><br>
    <a href="""+tunnelurl+""">"""+config.get('esend','eurltitle')+"""</a>.
    </p>
  </body>
</html>
"""

# Record the MIME types of both parts - text/plain and text/html.
part1 = MIMEText(text, 'plain')
part2 = MIMEText(html, 'html')

# Attach parts into message container.
msg.attach(part1)
msg.attach(part2)

mailserver = smtplib.SMTP(config.get('esend','esvr'),config.get('esend','esvrport'))
# identify ourselves to smtp gmail client
mailserver.ehlo()
# secure our email with tls encryption
mailserver.starttls()
# re-identify ourselves as an encrypted connection
mailserver.ehlo()
mailserver.login(config.get('esend','esvruser'),config.get('esend','esvrpass'))
mailserver.sendmail(msg['From'],msg['To'],msg.as_string())
mailserver.quit()
#Write a log entry

file = open(''+trupath+'/meyeconnect.log','a')
file.write('NOTIFICATION_MEYECONNECT: Y - Email Sent\n')
file.close() 
