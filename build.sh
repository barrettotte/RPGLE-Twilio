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


# +-----------------------------------------------------------------------------+
# |                          Project Configuration                              |
# |                  (directory paths, src build order, etc)                    |
# +-----------------------------------------------------------------------------+
BIN_LIB='BOLIB'

IFS_BASE=$(pwd)
IFS_SRC="$IFS_BASE/src"
IFC_CMD="$IFS_BASE/cmd"
IFS_DDS="$IFS_BASE/dds"
IFS_SQL="$IFS_BASE/sql"

LOG_DIR="$IFS_BASE/logs"
CCSID='37'
declare -a SRC_ORDER=("$BIN_LIB.lib" 'testwilio.rpgle')

# -> More powerful configuration below under 'CUSTOM' heading


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

# Clear objects out of library -> clean_lib(LIBRARY)
clear_lib(){
  exec_qsh "CLRLIB $1"
}

# Create TEST Library -> build_lib(LIBRARY)
build_lib(){
  exec_qsh "CRTLIB $1 TYPE(*TEST)"
}

# Delete an object -> delete_obj(OBJ,OBJTYPE) or delete_obj(LIB/OBJ,OBJTYPE)
delete_obj(){
  exec_qsh "DLTOBJ OBJ($1) OBJTYPE($2)"
}

# Generically build RPGLE
build_rpgle(){
  exec_qsh "CHGATR OBJ('$IFS_SRC/$1.rpgle') ATR(*CCSID) VALUE(1252)"
  exec_qsh "CRTSRCPF FILE($BIN_LIB/QRPGLESRC) RCDLEN(112) CCSID($CCSID)"
  exec_qsh "CRTBNDRPG PGM($BIN_LIB/$1) SRCSTMF('$IFS_SRC/$1.rpgle') OPTION(*NOUNREF) DBGVIEW(*LIST) INCDIR('./..')" -log "$1.rpgle"
}

# Generically build SQLRPGLE
build_sqlrpgle(){
  exec_qsh "CHGATR OBJ('$IFS_SRC/$1.sqlrpgle') ATR(*CCSID) VALUE(1252)"
  exec_qsh "CRTSRCPF FILE($BIN_LIB/QRPGLESRC) RCDLEN(112) CCSID($CCSID)"
  exec_qsh "CRTSQLRPGI OBJ($BIN_LIB/$1) SRCSTMF('$IFS_SRC/$1.sqlrpgle') RPGPPOPT(*LVL2) COMPILEOPT('OPTION(*NOUNREF) DBGVIEW(*LIST) INCDIR(''./..'')') DBGVIEW(*NONE) COMMIT(*NONE)" -log "$1.sqlrpgle"
}

# Generically build command
build_cmd(){
  exec_qsh "CHGATR OBJ('$IFS_CMD/$1.cmd') ATR(*CCSID) VALUE(1252)"
  exec_qsh "CRTSRCPF FILE($BIN_LIB/QCMDSRC) RCDLEN(132) CCSID($CCSID)"
  exec_qsh "CPYFRMSTMF FROMSTMF('$IFS_CMD/$1.cmd') TOMBR('/QSYS.lib/$BIN_LIB.lib/QCMDSRC.file/$1.mbr') MBROPT(*REPLACE)"
  exec_qsh "CRTCMD PRDLIB($BIN_LIB) CMD($BIN_LIB/$1) PGM($1) SRCFILE($BIN_LIB/QCMDSRC)" -log "$1.cmd"
}

# Generically build CL
build_clle(){
  exec_qsh "CRTSRCPF FILE($BIN_LIB/QCLLESRC) RCDLEN(112) CCSID($CCSID)"
  exec_qsh "CPYFRMSTMF FROMSTMF('$IFS_SRC/$1.clle') TOMBR('/QSYS.lib/$BIN_LIB.lib/QCLLESRC.file/$1.mbr') MBROPT(*REPLACE)"
  exec_qsh "CRTCLMOD MODULE($BIN_LIB/$1) SRCFILE($BIN_LIB/QCLLESRC) DBGVIEW(*ALL)" -log "$1.clle"
}

# Generically build display file
build_dspf(){
  exec_qsh "CHGATR OBJ('$IFS_SRC/$1.dspf') ATR(*CCSID) VALUE(1252)"
  exec_qsh "CRTSRCPF FILE($BIN_LIB/QDDSSRC) RCDLEN(132) CCSID($CCSID)"
  exec_qsh "CPYFRMSTMF FROMSTMF('$IFS_SRC/$1.dspf') TOMBR('/QSYS.lib/$BIN_LIB.lib/QDDSSRC.file/$1.mbr') MBROPT(*REPLACE)"
  exec_qsh "CRTDSPF FILE($BIN_LIB/$1) SRCFILE($BIN_LIB/QDDSSRC)" -log "$1.dspf"
}

# Generically build physical file
build_pf(){
  exec_qsh "CHGATR OBJ('$IFS_DDS/$1.pf') ATR(*CCSID) VALUE(1252)"
  exec_qsh "CRTSRCPF FILE($BIN_LIB/QDDSSRC) RCDLEN(132) CCSID($CCSID)"
  exec_qsh "CPYFRMSTMF FROMSTMF('$IFS_DDS/$1.pf') TOMBR('/QSYS.lib/$BIN_LIB.lib/QDDSSRC.file/$1.mbr') MBROPT(*REPLACE)"
  exec_qsh "CRTPF FILE($BIN_LIB/$1) SRCFILE($BIN_LIB/QDDSSRC)" -log "$1.pf"
}

# Generically build logical file
build_lf(){
  exec_qsh "CHGATR OBJ('$IFS_DDS/$1.lf') ATR(*CCSID) VALUE(1252)"
  exec_qsh "CRTSRCPF FILE($BIN_LIB/QDDSSRC) RCDLEN(132) CCSID($CCSID)"
  exec_qsh "CPYFRMSTMF FROMSTMF('$IFS_DDS/$1.lf') TOMBR('/QSYS.lib/$BIN_LIB.lib/QDDSSRC.file/$1.mbr') MBROPT(*REPLACE)"
  exec_qsh "CRTLF FILE($BIN_LIB/$1) SRCFILE($BIN_LIB/QDDSSRC)" -log "$1.lf"
}

# Generically build SQL file
build_sql(){
  exec_qsh "CHGATR OBJ('$IFS_SQL/$1.sql') ATR(*CCSID) VALUE(1252)"
  exec_qsh "RUNSQLSTM SRCSTMF('$IFS_SQL/$1.sql') COMMIT(*NONE) ERRLVL(30)" -log "$1.sql"
}

# Loop over SRC_ORDER configuration to build objects generically
generic_build(){
  for i in "${SRC_ORDER[@]}"; do 
    IFS='.' read -ra mbr <<< "$i"
    if   [ "${mbr[1]}" == 'sqlrpgle' ]; then build_sqlrpgle "${mbr[0]}"
    elif [ "${mbr[1]}" == 'lib' ];      then build_lib "${mbr[0]}"
    elif [ "${mbr[1]}" == 'rpgle' ];    then build_rpgle "${mbr[0]}"
    elif [ "${mbr[1]}" == 'cmd' ];      then build_cmd "${mbr[0]}"
    elif [ "${mbr[1]}" == 'cl' ];       then build_clle "${mbr[0]}"
    elif [ "${mbr[1]}" == 'clp' ];      then build_clle "${mbr[0]}"
    elif [ "${mbr[1]}" == 'clle' ];     then build_clle "${mbr[0]}"
    elif [ "${mbr[1]}" == 'dspf' ];     then build_dspf "${mbr[0]}"
    elif [ "${mbr[1]}" == 'sql' ];      then build_sql "${mbr[0]}"
    elif [ "${mbr[1]}" == 'pf' ];       then build_pf "${mbr[0]}"
    elif [ "${mbr[1]}" == 'lf' ];       then build_lf "${mbr[0]}"
    else echo "Unsupported file type '${mbr[0]}.${mbr[1]}'"
    fi
  done
}


# +-----------------------------------------------------------------------------+
# |                                     CUSTOM                                  |
# |                        (Edit the build process here)                        |
# |                                                                             |
# |                 NOTE: pre_build(), build(), post_build() are                |
# |                    automatically called below in that order                 |
# +-----------------------------------------------------------------------------+
pre_build(){
  echo 'Running pre-build...'
}

build(){
  echo 'Building...'
  generic_build
}

post_build(){
  echo 'Running post-build...'
}


# +-----------------------------------------------------------------------------+
# |                                     BUILD                                   |
# |                      (Shouldn't need to edit below here)                    | 
# +-----------------------------------------------------------------------------+
mkdir -p "$LOG_DIR"

pre_build
build
post_build
echo 'Done'
