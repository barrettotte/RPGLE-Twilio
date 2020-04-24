-- log Twilio SMS API requests

create or replace table TWILIO/sms_log(
  sid           varchar(64),
  date_created  varchar(64),
  date_updated  varchar(64),
  date_sent     varchar(64),
  account_sid   varchar(64),
  phone_to      varchar(32),
  phone_from    varchar(32),
  msg_srv_sid   varchar(64),
  body          varchar(1600),
  status        varchar(16),
  num_segments  varchar(8),
  num_media     varchar(8),
  direction     varchar(32),
  api_version   varchar(16),
  price         varchar(8),
  price_unit    varchar(4),
  error_code    varchar(8),
  error_message varchar(512),
  uri           varchar(256)
);
