**free
  // Test Twilio SMS API service program

  ctl-opt main(main);
  ctl-opt bnddir('TWILIO/TWILIO') actgrp(*new);
  ctl-opt option(*srcstmt:*nodebugio:*nounref) dftactgrp(*no);

  /include sms_h.rpgle

  dcl-pr main extpgm('TWILIOTEST') end-pr;


  // https://www.rpgpgm.com/2016/03/a-better-way-to-read-file-in-ifs-with.html
  dcl-pr fopen pointer extproc('_C_IFS_fopen');
    fileName pointer value options(*string);
    fileMode pointer value options(*string);
  end-pr;

  dcl-pr fgets pointer extproc('_C_IFS_fgets');
    line    pointer value;
    size    int(10) value;
    fstream pointer value;
  end-pr;

  dcl-pr fclose int(10) extproc('_C_IFS_fclose');
    fstream pointer value;
  end-pr;


  dcl-proc main;
    dcl-s  fpath   char(128);
    dcl-s  jsonStr varchar(4096);
    dcl-ds req     likeds(smsRequest);

    req.phone_to = *blanks;
    req.phone_from = *blanks;
    req.msg = 'Hello World';
    req.account = *blanks;
    req.auth = *blanks;

    fpath = '/home/OTTEB/RPGLE-Twilio/config.json' + x'00';
    jsonStr = readFileContents(fpath);

    // parse JSON file
    exec SQL
      select
        coalesce(phone_from,''),
        coalesce(account,''),
        coalesce(auth,'')
      into :req.phone_from, :req.account, :req.auth
      from json_table(
        :jsonStr, '$' columns(
          phone_from varchar(16) path 'lax $.phone_from',
          account    varchar(64) path 'lax $.account',
          auth       varchar(64) path 'lax $.auth'  
        )
      );

    // Get phone number target
    dsply 'Enter phone number: ' '' req.phone_to;
    req.phone_to = %trim(req.phone_to);

    testSimple(req);
    testVerbose(req);

    on-exit;
      *inlr = *on;
      return;
  end-proc;


  // read file contents into string
  dcl-proc readFileContents;
    dcl-pi *N varchar(4096);
      fpath char(128) value;
    end-pi;

    dcl-s contents   varchar(4096);
    dcl-s lineBuffer char(128);
    dcl-s fptr       pointer;
    dcl-s fmode      char(5);
    
    fmode = 'r' + x'00';
    fptr = fopen(%addr(fpath): %addr(fmode));
    
    if (fptr = *null);
      dsply ('Could not open file');
      return contents;
    endif;

    dow (fgets(%addr(lineBuffer): %size(lineBuffer): fptr) <> *null);
      lineBuffer = %xlate(x'00250D': '   ': lineBuffer); // LF,CR,NULL
      contents += %trimr(lineBuffer);
      clear lineBuffer;
    enddo;

    fclose(%addr(fpath));
    return contents; 
  end-proc;


  // test sendSms
  dcl-proc testSimple;
    dcl-pi *n;
      req likeds(smsRequest);
    end-pi;

    dcl-s err varchar(8);
    err = sendSms(req.phone_to: req.phone_from: req.msg: req.account: req.auth);

    if (err = *blanks);
      dsply ('Request successful!');
    else;
      dsply ('Request failed: ' + err);
    endif;
  end-proc;


  // test sendSmsVerbose
  dcl-proc testVerbose;
    dcl-ds resp likeds(smsResponse);
    dcl-ds req  likeds(smsRequest);

    resp = sendSmsVerbose(req);

    if (resp.error_code = *blanks);
      dsply ('Request successful!');
    else;
      dsply ('Request failed: ' + resp.error_code);
    endif;
  end-proc;
