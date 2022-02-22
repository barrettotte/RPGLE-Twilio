# RPGLE-Twilio-SMS
A really basic RPGLE service program to send a text with the Twilio SMS API. 

This is my introduction to making service programs, so its probably not great.
Originally I was going to submit this to the [Twilio Hackathon at DEV](https://dev.to/t/twiliohackathon),
but I decided I would just keep this as a small learning project instead.


## Summary
The service program has two procedures, **sendSms** and **sendSmsVerbose**.
* **sendSms** accepts 'simple' parms and returns an error code.
* **sendSmsVerbose** accepts a request data structure and returns the response as a data structure.

Additionally, each procedure logs the Twilio request/response to [sql/sms_log.sql](sql/sms_log.sql).
The service program is really only a wrapper over top of a stored procedure I wrote, [sql/send_sms.sql](sql/send_sms.sql).


## Setup
* Setup Twilio account and a Twilio phone number - https://www.twilio.com/
* Connect to IBMi via SSH - ```ssh USER@YOUR400```
* Clone project - ```git clone https://github.com/barrettotte/RPGLE-Twilio.git```
* Navigate to project - ```cd RPGLE-Twilio```
* Give permissions to build script - ```chmod u+x build.sh```
* Run build script - ```./build.sh```
* The build script will create the following
  * A Library named **TWILIO** to hold all of the Twilio objects
  * A Log table for logging SMS requests - **sms_log**
  * A simplified view over the log table -> **sms_log_v**
  * A stored procedure to call Twilio SMS API -> **send_sms**
  * An RPGLE service program to call Twilio SMS API -> ```ctl-opt bnddir('TWILIO/TWILIO') actgrp(*new);```
* Example call in [example/src/testtwilio.sqlrpgle](example/src/testtwilio.sqlrpgle)


## Commands
* give permissions to build script and build project - ```chmod u+x build.sh & ./build.sh```
* git push - ```git -c http.sslVerify=false push origin master```


## References
* [Twilio SMS docs](https://www.twilio.com/docs/sms)
* [Twilio SMS Python Quickstart](https://www.twilio.com/docs/sms/quickstart/python)
* [Read IFS files with RPG](https://www.rpgpgm.com/2016/01/read-ifs-file-using-rpg.html)
* [Writing and reading IFS files](https://github.com/worksofliam/blog/issues/12)
