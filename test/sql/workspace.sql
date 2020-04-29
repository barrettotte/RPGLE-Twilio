-- general snippets used in testing stuff


select *
from QSYS2.SYSTABLES
where TABLE_NAME='SMS_LOG'
;


select *
from QSYS2.SYSPROCS
where SPECIFIC_NAME='SENDSMS'
limit 10;


select *
from twilio.sms_log
limit 25;


select *
from twilio.sms_log_v
limit 25;
