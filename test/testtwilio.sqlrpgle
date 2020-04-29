**free
  // Test Twilio SMS API service program

  ctl-opt main(main);
  //ctl-opt bnddir('TWILIO/TWILIO') actgrp(*new);
  ctl-opt option(*srcstmt:*nodebugio:*nounref) dftactgrp(*no);

  dcl-pr main extpgm('TWILIOTEST') end-pr;
  // /include sms_h.rpgle

  dcl-proc main;

    dsply (%char(%time)); // TODO: remove
    

    on-exit;
      *inlr = *on;
      return;
  end-proc;


  

