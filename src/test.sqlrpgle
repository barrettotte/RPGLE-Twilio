**free
  // Test Twilio SMS API service program

  ctl-opt main(main);
  //ctl-opt bnddir('TWILIOSMS/SMS') actgrp(*new);
  ctl-opt option(*srcstmt:*nodebugio:*nounref) DFTACTGRP(*NO) alwnull(*usrctl);

  dcl-pr main extpgm('PRIVATE') end-pr;
  /include inc/sms_h.rpgle

  dcl-proc main;
    
    dcl-s err varchar(8) inz(*blanks);

    dcl-s phone_to   varchar(16) inz('');
    dcl-s phone_from varchar(16) inz('');
    dcl-s msg        varchar(1600) inz('Hello World');
    dcl-s account    varchar(64) inz('');
    dcl-s auth       varchar(64) inz('');

    err = sendSms(phone_to:phone_from:msg:account:auth);

    if (err <> *blanks);
      dsply ('all was good');
    else;
      dsply ('error: ' + err);
    endif;

    on-exit;
      *inlr = *on;
      return;
  end-proc;


dcl-proc sendSms;
  dcl-pi *N    varchar(8);
    phone_to   varchar(16);
    phone_from varchar(16);
    msg        varchar(1600);
    account    varchar(64);
    auth       varchar(64);
  end-pi;

  dcl-ds resp likeds(smsResponse);
  //dcl-s  resp_rs sqltype(RESULT_SET_LOCATOR);

  exec SQL 
    set option COMMIT=*NONE;
  
  exec SQL
    select x.*
    into :resp
    from json_table(
      SysTools.HttpPostClob(
        'https://api.twilio.com/2010-04-01/Accounts/' || trim(:account) || '/Messages.json',
        cast((
          '<httpHeader>' ||
            '<header name="Authorization" value="Basic ' || trim(SysTools.Base64Encode(
              cast((trim(:account) || ':' || trim(:auth)) as varchar(256) ccsid 1208))) ||
            '"/>' ||
            '<header name="Accept" value="application/json"/>' ||
            '<header name="Content-Type" value="application/x-www-form-urlencoded"/>' ||
          '</httpHeader>'
        ) as clob),
        cast((
          'To='    || SysTools.UrlEncode(trim(:phone_to), 'UTF-8') ||
          '&From=' || SysTools.UrlEncode(trim(:phone_from), 'UTF-8') ||
          '&Body=' || SysTools.UrlEncode(trim(:msg), 'UTF-8')
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
    ) as x;

  //exec SQL 
  //  call TWILIO/SENDSMS(:phone_to, :phone_from, :msg, :account, :auth);
  //exec SQL 
  //  associate result set locator (:resp_rs) with procedure TWILIO/SENDSMS;
  //exec SQL
  //  allocate c1 cursor for result set :resp_rs;
  //exec SQL
  //  fetch next from c1 into :resp;
  //exec SQL
  //  close c1;
  
  return resp.error_code;
end-proc;