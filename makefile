# Build the Db2 for i encryption examples.
#
#   gmake                    -> builds everything into library SECRETS
#   gmake BIN_LIB=MYLIB      -> builds everything into library MYLIB
#
# The library is created if it does not exist. Source paths are taken
# from the directory where gmake runs, so the project can live anywhere
# in the IFS.

BIN_LIB ?= SECRETS
SHELL   = /QOpenSys/usr/bin/qsh
SRCDIR  = $(CURDIR)
# The sources are plain ASCII. They are tagged 1252 because the RPG compiler
# does not accept a Unicode (1208) source with its default TGTCCSID(*SRC).
CCSID   = 1252

.PHONY: all lib

all: secrets.sql secretadd.sqlrpgle secretget.sqlrpgle

# The table must exist before the programs that use it are compiled.
secrets.sql: lib
secretadd.sqlrpgle secretget.sqlrpgle: secrets.sql

lib:
	-system -q "CRTLIB LIB($(BIN_LIB)) TEXT('Db2 for i encryption examples')"

%.sql:
	system -s "CHGATR OBJ('$(SRCDIR)/qsqlsrc/$*.sql') ATR(*CCSID) VALUE($(CCSID))"
	system "RUNSQLSTM SRCSTMF('$(SRCDIR)/qsqlsrc/$*.sql') COMMIT(*NONE) NAMING(*SQL) DFTRDBCOL($(BIN_LIB)) ERRLVL(20)"

%.sqlrpgle:
	system -s "CHGATR OBJ('$(SRCDIR)/qrpglesrc/$*.sqlrpgle') ATR(*CCSID) VALUE($(CCSID))"
	system "CRTSQLRPGI OBJ($(BIN_LIB)/$*) SRCSTMF('$(SRCDIR)/qrpglesrc/$*.sqlrpgle') OBJTYPE(*PGM) COMMIT(*NONE) DFTRDBCOL($(BIN_LIB)) DBGVIEW(*SOURCE) OPTION(*EVENTF) RPGPPOPT(*LVL2)"
