**free
  //
  // Test Twilio API using service program
  //

  ctl-opt main(main);
  ctl-opt option(*srcstmt:*nodebugio:*nounref) dftactgrp(*no);
  ctl-opt datfmt(*iso) timfmt(*iso);

  dcl-pr main extpgm('TESTWILIO') end-pr;

  dcl-proc main;
    dsply ('Testing build script...');

    on-exit;
      *inlr = *on;
      return;
  end-proc;
