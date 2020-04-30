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


## Commands
* give permissions to build script and build project - ```chmod u+x build.sh & ./build.sh```
* git push - ```git -c http.sslVerify=false push origin master```


## References
* [Twilio SMS docs](https://www.twilio.com/docs/sms)
* [Twilio SMS Python Quickstart](https://www.twilio.com/docs/sms/quickstart/python)
* [Read IFS files with RPG](https://www.rpgpgm.com/2016/01/read-ifs-file-using-rpg.html)
* [Writing and reading IFS files](https://github.com/worksofliam/blog/issues/12)
