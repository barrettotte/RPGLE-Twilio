/*
Purpose: Hit Twilio SMS API
Usage: call TWILIOSMS/send_sms('{{to}}','{{from}}','Hello World','{{account}}','{{auth}}');
*/

create or replace procedure TWILIO/send_sms ( 
    phone_to   varchar(16),
    phone_from varchar(16),
    msg        varchar(1600),
    account    varchar(64),  
    auth       varchar(64)
)
  LANGUAGE SQL
  SPECIFIC TWILIO/SENDSMS
  DYNAMIC RESULT SETS 1
  SET OPTION DBGVIEW = *SOURCE,
             CLOSQLCSR = *ENDACTGRP

  
begin
  declare sms_csr cursor with return for
    select *
    from json_table(
      SysTools.HttpPostClob(
        'https://api.twilio.com/2010-04-01/Accounts/' || trim(account) || '/Messages.json',
        cast((
          '<httpHeader>
            <header name="Authorization" value="Basic ' || trim(SysTools.Base64Encode(
              cast((trim(account) || ':' || trim(auth)) as varchar(256) ccsid 1208))) ||
            '"/>
            <header name="Accept" value="application/json"/>
            <header name="Content-Type" value="application/x-www-form-urlencoded"/>
          </httpHeader>'
        ) as clob),
        cast((
          'To='    || SysTools.UrlEncode(trim(phone_to), 'UTF-8') ||
          '&From=' || SysTools.UrlEncode(trim(phone_from), 'UTF-8') ||
          '&Body=' || SysTools.UrlEncode(trim(msg), 'UTF-8')
        ) as clob)
      ),
      '$' columns(
        sid           varchar(64)   path 'lax $.sid',
        date_created  varchar(64)   path 'lax $.date_created',
        date_updated  varchar(64)   path 'lax $.date_updated',
        date_sent     varchar(64)   path 'lax $.date_sent',
        account_sid   varchar(64)   path 'lax $.account_sid',
        phone_to      varchar(32)   path 'lax $.to',
        phone_from    varchar(32)   path 'lax $.from',
        msg_srv_sid   varchar(64)   path 'lax $.messaging_service_sid',
        body          varchar(1600) path 'lax $.body',
        status        varchar(16)   path 'lax $.status',
        num_segments  varchar(8)    path 'lax $.num_segments',
        num_media     varchar(8)    path 'lax $.num_media',
        direction     varchar(32)   path 'lax $.direction',
        api_version   varchar(16)   path 'lax $.api_version',
        price         varchar(8)    path 'lax $.price',
        price_unit    varchar(4)    path 'lax $.price_unit',
        error_code    varchar(8)    path 'lax $.error_code',
        error_message varchar(512)  path 'lax $.error_message',
        uri           varchar(256)  path 'lax $.uri'
      )
    );
  open sms_csr;
  
end;
