:global emailBody;
:global updateVersion;
:global deviceName;
:global emailSubject;

# Specify notifications emails receiver
:local to "notification.email@example.com"

/tool e-mail send to=$to subject=$emailSubject body=$emailBody