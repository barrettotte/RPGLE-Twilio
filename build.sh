#!/QOpenSys/pkgs/bin/bash
#
# https://gist.github.com/barrettotte/278e1e97fc2ba23c7ad6366b0b4c8668
#
# Give permission:   $ chmod u+x build.sh
#
# Directory structure:
#   cmd/ - .cmd
#   dds/ - .pf .lf
#   sql/ - .sql
#   src/ - .rpgle .sqlrpgle .clle .dspf
#
# Usage:
#   $ build.sh         (build normally)
#   $ build.sh -dds    (build normally and recreate PFs and LFs)
#
BIN_LIB='OTTEB1'
IFS_BASE=$(pwd)
IFS_SRC="$IFS_BASE/src"
IFC_CMD="$IFS_BASE/cmd"
IFS_DDS="$IFS_BASE/dds"
IFS_SQL="$IFS_BASE/sql"
LOG_DIR="$IFS_BASE/logs"

declare -a DDS_ORDER=()
declare -a SRC_ORDER=("$BIN_LIB.lib" 'testwilio.rpgle')
CCSID='37'
# -------------------------------------------------------------------------------

exec_qsh(){
  echo $1
  output=$(qsh -c "liblist -a $BIN_LIB ; system \"$1\"")
  if [ "$2" == "-log" ]; then
    echo -e "$1\n\n$output" > "$LOG_DIR/$3.log"
  fi
}

build_lib(){
  exec_qsh "CRTLIB $1 TYPE(*TEST)"
}

build_rpgle(){
  exec_qsh "CHGATR OBJ('$IFS_SRC/$1.rpgle') ATR(*CCSID) VALUE(1252)"
  exec_qsh "CRTSRCPF FILE($BIN_LIB/QRPGLESRC) RCDLEN(112) CCSID($CCSID)"
  exec_qsh "CRTBNDRPG PGM($BIN_LIB/$1) SRCSTMF('$IFS_SRC/$1.rpgle') OPTION(*NOUNREF) DBGVIEW(*LIST) INCDIR('./..')" -log "$1.rpgle"
}

build_sqlrpgle(){
  exec_qsh "CHGATR OBJ('$IFS_SRC/$1.sqlrpgle') ATR(*CCSID) VALUE(1252)"
  exec_qsh "CRTSRCPF FILE($BIN_LIB/QRPGLESRC) RCDLEN(112) CCSID($CCSID)"
  exec_qsh "CRTSQLRPGI OBJ($BIN_LIB/$1) SRCSTMF('$IFS_SRC/$1.sqlrpgle') RPGPPOPT(*LVL2) COMPILEOPT('OPTION(*NOUNREF) DBGVIEW(*LIST) INCDIR(''./..'')') DBGVIEW(*NONE) COMMIT(*NONE)" -log "$1.sqlrpgle"
}

build_cmd(){
  exec_qsh "CHGATR OBJ('$IFS_CMD/$1.cmd') ATR(*CCSID) VALUE(1252)"
  exec_qsh "CRTSRCPF FILE($BIN_LIB/QCMDSRC) RCDLEN(132) CCSID($CCSID)"
  exec_qsh "CPYFRMSTMF FROMSTMF('$IFS_CMD/$1.cmd') TOMBR('/QSYS.lib/$BIN_LIB.lib/QCMDSRC.file/$1.mbr') MBROPT(*REPLACE)"
  exec_qsh "CRTCMD PRDLIB($BIN_LIB) CMD($BIN_LIB/$1) PGM($1) SRCFILE($BIN_LIB/QCMDSRC)" -log "$1.cmd"
}

build_clle(){
  exec_qsh "CRTSRCPF FILE($BIN_LIB/QCLLESRC) RCDLEN(112) CCSID($CCSID)"
  exec_qsh "CPYFRMSTMF FROMSTMF('$IFS_SRC/$1.clle') TOMBR('/QSYS.lib/$BIN_LIB.lib/QCLLESRC.file/$1.mbr') MBROPT(*REPLACE)"
  exec_qsh "CRTCLMOD MODULE($BIN_LIB/$1) SRCFILE($BIN_LIB/QCLLESRC) DBGVIEW(*ALL)" -log "$1.clle"
}

build_dspf(){
  exec_qsh "CHGATR OBJ('$IFS_SRC/$1.dspf') ATR(*CCSID) VALUE(1252)"
  exec_qsh "CRTSRCPF FILE($BIN_LIB/QDDSSRC) RCDLEN(132) CCSID($CCSID)"
  exec_qsh "CPYFRMSTMF FROMSTMF('$IFS_SRC/$1.dspf') TOMBR('/QSYS.lib/$BIN_LIB.lib/QDDSSRC.file/$1.mbr') MBROPT(*REPLACE)"
  exec_qsh "CRTDSPF FILE($BIN_LIB/$1) SRCFILE($BIN_LIB/QDDSSRC)" -log "$1.dspf"
}

build_pf(){
  exec_qsh "CHGATR OBJ('$IFS_DDS/$1.pf') ATR(*CCSID) VALUE(1252)"
  exec_qsh "CRTSRCPF FILE($BIN_LIB/QDDSSRC) RCDLEN(132) CCSID($CCSID)"
  exec_qsh "CPYFRMSTMF FROMSTMF('$IFS_DDS/$1.pf') TOMBR('/QSYS.lib/$BIN_LIB.lib/QDDSSRC.file/$1.mbr') MBROPT(*REPLACE)"
  exec_qsh "DLTOBJ OBJ($BIN_LIB/$1) OBJTYPE(*FILE)"
  exec_qsh "CRTPF FILE($BIN_LIB/$1) SRCFILE($BIN_LIB/QDDSSRC)" -log "$1.pf"
}

build_lf(){
  exec_qsh "CHGATR OBJ('$IFS_DDS/$1.lf') ATR(*CCSID) VALUE(1252)"
  exec_qsh "CRTSRCPF FILE($BIN_LIB/QDDSSRC) RCDLEN(132) CCSID($CCSID)"
  exec_qsh "CPYFRMSTMF FROMSTMF('$IFS_DDS/$1.lf') TOMBR('/QSYS.lib/$BIN_LIB.lib/QDDSSRC.file/$1.mbr') MBROPT(*REPLACE)"
  exec_qsh "DLTOBJ OBJ($BIN_LIB/$1) OBJTYPE(*FILE)"
  exec_qsh "CRTLF FILE($BIN_LIB/$1) SRCFILE($BIN_LIB/QDDSSRC)" -log "$1.lf"
}

build_sql(){
  exec_qsh "CHGATR OBJ('$IFS_SQL/$1.sql') ATR(*CCSID) VALUE(1252)"
  exec_qsh "RUNSQLSTM SRCSTMF('$IFS_SQL/$1.sql') COMMIT(*NONE) ERRLVL(30)" -log "$1.sql"
}
# -------------------------------------------------------------------------------

# Setup
mkdir -p "$LOG_DIR"

# Build PFs and LFs (recreates objects)
if [ "$1" == '-dds' ]; then
  for i in "${DDS_ORDER[@]}"; do
    IFS='.' read -ra dds <<< "$i"
    if   [ "${dds[1]}" == 'pf' ]; then build_pf "${dds[0]}"
    elif [ "${dds[1]}" == 'lf' ]; then build_lf "${dds[0]}"
    else echo "Invalid file type '${dds[0]}.${dds[1]}'"
    fi
  done
fi

for i in "${SRC_ORDER[@]}"; do 
  IFS='.' read -ra mbr <<< "$i"
  if   [ "${mbr[1]}" == 'sqlrpgle' ]; then build_sqlrpgle "${mbr[0]}"
  elif [ "${mbr[1]}" == 'lib' ];      then build_lib "${mbr[0]}"
  elif [ "${mbr[1]}" == 'rpgle' ];    then build_rpgle "${mbr[0]}"
  elif [ "${mbr[1]}" == 'cmd' ];      then build_cmd "${mbr[0]}"
  elif [ "${mbr[1]}" == 'clle' ];     then build_clle "${mbr[0]}"
  elif [ "${mbr[1]}" == 'dspf' ];     then build_dspf "${mbr[0]}"
  elif [ "${mbr[1]}" == 'sql' ];      then build_sql "${mbr[0]}"
  else echo "Invalid file type '${mbr[0]}.${mbr[1]}'"
  fi
done

echo 'Build Finished!'
