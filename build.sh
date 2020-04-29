#!/QOpenSys/pkgs/bin/bash
#
# Source:
#   https://gist.github.com/barrettotte/278e1e97fc2ba23c7ad6366b0b4c8668
#
# Give permission:   $ chmod u+x build.sh
#
# Example project structure:
#   cmd/ - .cmd
#   dds/ - .pf .lf
#   sql/ - .sql
#   src/ - .rpgle .sqlrpgle .clle .dspf .bnd
#
# Truthfully I don't like this build script or the generic makefile I've used
#   in other projects. One day I want to make a build system/script that
#   "just works" and makes sense with little specific coding...

# +-----------------------------------------------------------------------------+
# |                          Project Configuration                              |
# |                  (directory paths, src build order, etc)                    |
# +-----------------------------------------------------------------------------+
BIN_LIB='TWILIO'

IFS_BASE=$(pwd)
IFS_SRC="$IFS_BASE/src"
IFC_CMD="$IFS_BASE/cmd"
IFS_DDS="$IFS_BASE/dds"
IFS_SQL="$IFS_BASE/sql"

LOG_DIR="$IFS_BASE/logs"
CCSID='37'


# +-----------------------------------------------------------------------------+
# |                              UTILITY FUNCTIONS                              |
# |                      (Shouldn't need to edit these)                         |
# +-----------------------------------------------------------------------------+
exec_qsh(){
  echo $1
  output=$(qsh -c "liblist -a $BIN_LIB ; system \"$1\"")
  if [ "$2" == "-log" ]; then
    echo -e "$1\n\n$output" > "$LOG_DIR/$3.log"
  fi
}

clear_lib(){
  echo ' '
  exec_qsh "CLRLIB $1"
}

build_lib(){
  echo ' '
  exec_qsh "CRTLIB LIB($1) TYPE($2) TEXT('$3')"
}

delete_obj(){
  echo ' '
  exec_qsh "DLTOBJ OBJ($1) OBJTYPE($2)"
}

build_rpgle(){
  echo ' '
  exec_qsh "CHGATR OBJ('$IFS_SRC/$1.rpgle') ATR(*CCSID) VALUE(1252)"
  exec_qsh "CRTSRCPF FILE($BIN_LIB/QRPGLESRC) RCDLEN(112) CCSID($CCSID)"
  exec_qsh "CPYFRMSTMF FROMSTMF('$IFS_SRC/$1.rpgle') TOMBR('/QSYS.lib/$BIN_LIB.lib/QRPGLESRC.file/$1.mbr') MBROPT(*REPLACE)"
  exec_qsh "CHGPFM FILE($BIN_LIB/QRPGLESRC) MBR($1) SRCTYPE(RPGLE) TEXT('$2')"
  exec_qsh "CRTBNDRPG PGM($BIN_LIB/$1) SRCSTMF('$IFS_SRC/$1.rpgle') OPTION(*NOUNREF) DBGVIEW(*LIST) INCDIR('$IFS_SRC')" -log "$1.rpgle"
}

# build_sqlrpgle 'MBR' 'TEXT' 'OBJTYPE'
build_sqlrpgle(){
  echo ' '
  exec_qsh "CHGATR OBJ('$IFS_SRC/$1.sqlrpgle') ATR(*CCSID) VALUE(1252)"
  exec_qsh "CRTSRCPF FILE($BIN_LIB/QRPGLESRC) RCDLEN(112) CCSID($CCSID)"
  exec_qsh "CPYFRMSTMF FROMSTMF('$IFS_SRC/$1.sqlrpgle') TOMBR('/QSYS.lib/$BIN_LIB.lib/QRPGLESRC.file/$1.mbr') MBROPT(*REPLACE)"
  exec_qsh "CHGPFM FILE($BIN_LIB/QRPGLESRC) MBR($1) SRCTYPE(SQLRPGLE) TEXT('$2')"
  objtype=${3:-'*PGM'}
  exec_qsh "CRTSQLRPGI OBJ($BIN_LIB/$1) SRCSTMF('$IFS_SRC/$1.sqlrpgle') RPGPPOPT(*LVL2) COMPILEOPT('OPTION(*NOUNREF) DBGVIEW(*SOURCE) INCDIR(''$IFS_SRC'')') DBGVIEW(*NONE) COMMIT(*NONE) OBJTYPE($objtype)" -log "$1.sqlrpgle"
}

build_cmd(){
  echo ' '
  exec_qsh "CHGATR OBJ('$IFS_CMD/$1.cmd') ATR(*CCSID) VALUE(1252)"
  exec_qsh "CRTSRCPF FILE($BIN_LIB/QCMDSRC) RCDLEN(132) CCSID($CCSID)"
  exec_qsh "CPYFRMSTMF FROMSTMF('$IFS_CMD/$1.cmd') TOMBR('/QSYS.lib/$BIN_LIB.lib/QCMDSRC.file/$1.mbr') MBROPT(*REPLACE)"
  exec_qsh "CHGPFM FILE($BIN_LIB/QCMDSRC) MBR($1) SRCTYPE(CMD) TEXT('$2')"
  exec_qsh "CRTCMD PRDLIB($BIN_LIB) CMD($BIN_LIB/$1) PGM($1) SRCFILE($BIN_LIB/QCMDSRC)" -log "$1.cmd"
}

build_clle(){
  echo ' '
  exec_qsh "CRTSRCPF FILE($BIN_LIB/QCLLESRC) RCDLEN(112) CCSID($CCSID)"
  exec_qsh "CPYFRMSTMF FROMSTMF('$IFS_SRC/$1.clle') TOMBR('/QSYS.lib/$BIN_LIB.lib/QCLLESRC.file/$1.mbr') MBROPT(*REPLACE)"
  exec_qsh "CHGPFM FILE($BIN_LIB/QCLLESRC) MBR($1) SRCTYPE(CLLE) TEXT('$2')"
  exec_qsh "CRTCLMOD MODULE($BIN_LIB/$1) SRCFILE($BIN_LIB/QCLLESRC) DBGVIEW(*ALL)" -log "$1.clle"
}

build_dspf(){
  echo ' '
  exec_qsh "CHGATR OBJ('$IFS_SRC/$1.dspf') ATR(*CCSID) VALUE(1252)"
  exec_qsh "CRTSRCPF FILE($BIN_LIB/QDDSSRC) RCDLEN(132) CCSID($CCSID)"
  exec_qsh "CPYFRMSTMF FROMSTMF('$IFS_SRC/$1.dspf') TOMBR('/QSYS.lib/$BIN_LIB.lib/QDDSSRC.file/$1.mbr') MBROPT(*REPLACE)"
  exec_qsh "CHGPFM FILE($BIN_LIB/QDDSSRC) MBR($1) SRCTYPE(DSPF) TEXT('$2')"
  exec_qsh "CRTDSPF FILE($BIN_LIB/$1) SRCFILE($BIN_LIB/QDDSSRC)" -log "$1.dspf"
}

build_pf(){
  echo ' '
  exec_qsh "CHGATR OBJ('$IFS_DDS/$1.pf') ATR(*CCSID) VALUE(1252)"
  exec_qsh "CRTSRCPF FILE($BIN_LIB/QDDSSRC) RCDLEN(132) CCSID($CCSID)"
  exec_qsh "CPYFRMSTMF FROMSTMF('$IFS_DDS/$1.pf') TOMBR('/QSYS.lib/$BIN_LIB.lib/QDDSSRC.file/$1.mbr') MBROPT(*REPLACE)"
  exec_qsh "CHGPFM FILE($BIN_LIB/QDDSSRC) MBR($1) SRCTYPE(PF) TEXT('$2')"
  exec_qsh "CRTPF FILE($BIN_LIB/$1) SRCFILE($BIN_LIB/QDDSSRC)" -log "$1.pf"
}

build_lf(){
  echo ' '
  exec_qsh "CHGATR OBJ('$IFS_DDS/$1.lf') ATR(*CCSID) VALUE(1252)"
  exec_qsh "CRTSRCPF FILE($BIN_LIB/QDDSSRC) RCDLEN(132) CCSID($CCSID)"
  exec_qsh "CPYFRMSTMF FROMSTMF('$IFS_DDS/$1.lf') TOMBR('/QSYS.lib/$BIN_LIB.lib/QDDSSRC.file/$1.mbr') MBROPT(*REPLACE)"
  exec_qsh "CHGPFM FILE($BIN_LIB/QDDSSRC) MBR($1) SRCTYPE(LF) TEXT('$2')"
  exec_qsh "CRTLF FILE($BIN_LIB/$1) SRCFILE($BIN_LIB/QDDSSRC)" -log "$1.lf"
}

build_sql(){
  echo ' '
  exec_qsh "CHGATR OBJ('$IFS_SQL/$1.sql') ATR(*CCSID) VALUE(1252)"
  exec_qsh "CRTSRCPF FILE($BIN_LIB/QSQLSRC) RCDLEN(132) CCSID($CCSID)"
  exec_qsh "CPYFRMSTMF FROMSTMF('$IFS_SQL/$1.sql') TOMBR('/QSYS.lib/$BIN_LIB.lib/QSQLSRC.file/$1.mbr') MBROPT(*REPLACE)"
  exec_qsh "CHGPFM FILE($BIN_LIB/QSQLSRC) MBR($1) SRCTYPE(SQL) TEXT('$2')"
  exec_qsh "RUNSQLSTM SRCSTMF('$IFS_SQL/$1.sql') COMMIT(*NONE) ERRLVL(30)" -log "$1.sql"
}

build_bnd(){
  echo ' '
  exec_qsh "CHGATR OBJ('$IFS_SRC/$1.bnd') ATR(*CCSID) VALUE(1252)"
  exec_qsh "CRTSRCPF FILE($BIN_LIB/QSRVSRC) RCDLEN(112) CCSID($CCSID)"
  exec_qsh "CPYFRMSTMF FROMSTMF('$IFS_SRC/$1.bnd') TOMBR('/QSYS.lib/$BIN_LIB.lib/QSRVSRC.file/$1.mbr') MBROPT(*REPLACE)"
  exec_qsh "CHGPFM FILE($BIN_LIB/QSRVSRC) MBR($1) SRCTYPE(BND) TEXT('$2')"
}

# Generically build object based on file extension  ->  build_obj 'MBR.ext' 'TEXT'
build_obj(){
  IFS='.' read -ra mbr <<< "$1"
  if   [ "${mbr[1]}" == 'sqlrpgle' ]; then build_sqlrpgle "${mbr[0]}" "$2"
  elif [ "${mbr[1]}" == 'rpgle' ];    then build_rpgle "${mbr[0]}" "$2"
  elif [ "${mbr[1]}" == 'cmd' ];      then build_cmd "${mbr[0]}" "$2"
  elif [ "${mbr[1]}" == 'cl' ];       then build_clle "${mbr[0]}" "$2"
  elif [ "${mbr[1]}" == 'clp' ];      then build_clle "${mbr[0]}" "$2"
  elif [ "${mbr[1]}" == 'clle' ];     then build_clle "${mbr[0]}" "$2"
  elif [ "${mbr[1]}" == 'dspf' ];     then build_dspf "${mbr[0]}" "$2"
  elif [ "${mbr[1]}" == 'sql' ];      then build_sql "${mbr[0]}" "$2"
  elif [ "${mbr[1]}" == 'pf' ];       then build_pf "${mbr[0]}" "$2"
  elif [ "${mbr[1]}" == 'lf' ];       then build_lf "${mbr[0]}" "$2"
  elif [ "${mbr[1]}" == 'bnd' ];      then build_bnd "${mbr[0]}" "$2"
  else echo "Unsupported file type '${mbr[0]}.${mbr[1]}'"
  fi
}


# +-----------------------------------------------------------------------------+
# |                                     CUSTOM                                  |
# |                        (Edit the build process here)                        |
# |                                                                             |
# |                 NOTE: pre_build(), build(), post_build() are                |
# |                    automatically called below in that order                 |
# +-----------------------------------------------------------------------------+
pre_build(){
  echo '========================================================================'
  echo -e '\nRunning pre-build...'
  rm $LOG_DIR/*.log
  build_lib "$BIN_LIB" '*TEST' 'Twilio'
}

build(){
  echo -e '\nBuilding...'
  
  #build_obj 'sms_log.sql' 'Log Twilio SMS Requests'
  #build_obj 'sms_log_v.sql' 'Simplified SMS Log View'
  #build_obj 'send_sms.sql' 'Hit Twilio SMS API'

  exec_qsh "CRTBNDDIR BNDDIR($BIN_LIB/TWILIO) TEXT('Twilio Binding Directory')"
  build_sqlrpgle 'sms' 'Twilio SMS module' '*MODULE'
  build_obj 'twiliosms.bnd' 'Twilio SMS Service Binding'
  exec_qsh "CRTSRVPGM SRVPGM($BIN_LIB/TWILIOSMS) MODULE($BIN_LIB/SMS) EXPORT(*SRCFILE) SRCSTMF('$IFS_SRC/twiliosms.bnd') TEXT('Twilio SMS Service') BNDDIR($BIN_LIB/TWILIO)"


  # CRTRPGMOD
  # CRTSRVPGM
  # DLTOBJ *MODULE
  # CRTBNDDIR
  # ADDBNDDIRE

  # build_obj 'private.sqlrpgle' 'Test Twilio SMS API'

}

post_build(){
  echo -e '\nRunning post-build...'
}


# +-----------------------------------------------------------------------------+
# |                                     BUILD                                   |
# |                      (Shouldn't need to edit below here)                    | 
# +-----------------------------------------------------------------------------+
mkdir -p "$LOG_DIR"

pre_build
build
post_build
echo -e '\nDone.'
