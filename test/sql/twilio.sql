-- Test calling Twilio SMS API



-- URL encode test
values cast(SysTools.UrlEncode('To={{to}}&From={{from}}&Body=Hello World', 'UTF-8') as clob);
 


-- HTTP POST to Twilio SMS API and get basic response
select *
from table(
  SysTools.HttpPostClobVerbose(
    'https://api.twilio.com/2010-04-01/Accounts/{{account}}/Messages.json',
    cast((
      '<httpHeader>
        <header name="Authorization" value="Basic ' || trim(SysTools.Base64Encode(
          cast('{{account}}:{{auth}}' as varchar(256) ccsid 1208))) ||
        '"/>
        <header name="Accept" value="application/json"/>
        <header name="Content-Type" value="application/x-www-form-urlencoded"/>
      </httpHeader>'
    ) as clob),
    cast((
      'To='    || SysTools.UrlEncode('{{to}}', 'UTF-8') ||
      '&From=' || SysTools.UrlEncode('{{from}}', 'UTF-8') ||
      '&Body=' || SysTools.UrlEncode('Hello World', 'UTF-8')
    ) as clob)
  )
);



-- HTTP POST to Twilio SMS API and get response as table
select *
from json_table(
  SysTools.HttpPostClob(
    'https://api.twilio.com/2010-04-01/Accounts/{{account}}/Messages.json',
    cast((
      '<httpHeader>
        <header name="Authorization" value="Basic ' || trim(SysTools.Base64Encode(
          cast('{{account}}:{{auth}}' as varchar(256) ccsid 1208))) ||
        '"/>
        <header name="Accept" value="application/json"/>
        <header name="Content-Type" value="application/x-www-form-urlencoded"/>
      </httpHeader>'
    ) as clob),
    cast((
      'To='    || SysTools.UrlEncode('{{to}}', 'UTF-8') ||
      '&From=' || SysTools.UrlEncode('{{from}}', 'UTF-8') ||
      '&Body=' || SysTools.UrlEncode('Hello World', 'UTF-8')
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
    uri           varchar(256)  path 'lax $.uri',
    nested '$.subresource_uris[*]' columns(
      media       varchar(256)  path 'lax $.media'
    )
  )
);
