-- Simplified view over Twilio SMS API Request log

create or replace view TWILIO/sms_log_v as
  select
      sid,
      date_created,
      phone_to,
      phone_from,
      body,
      error_code,
      error_message
  from TWILIO/sms_log
;
