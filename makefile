BIN_LIB=CMPSYS
LIBLIST=$(BIN_LIB) CLV1
SHELL=/QOpenSys/usr/bin/qsh

all: secret1.sql 

%.sqlrpgle:
	system -s "CHGATR OBJ('/home/CLV/secrets/qrpglesrc/$*.sqlrpgle') ATR(*CCSID) VALUE(1252)"
	liblist -a $(LIBLIST);\
	system "CRTSQLRPGI OBJ($(BIN_LIB)/$*) SRCSTMF('/home/CLV/secrets/qrpglesrc/$*.sqlrpgle') COMMIT(*CHG) DBGVIEW(*SOURCE) OPTION(*EVENTF) OBJTYPE(*MODULE) RPGPPOPT(*LVL2)"
	system "CRTPGM PGM($(BIN_LIB)/$*) MODULE($(BIN_LIB)/$*)"
	system "DLTOBJ OBJ($(BIN_LIB)/$*) OBJTYPE(*MODULE)"

%.rpgle:
	system -s "CHGATR OBJ('/home/CLV/secrets/qrpglesrc/$*.rpgle') ATR(*CCSID) VALUE(1252)"
	liblist -a $(LIBLIST);\
	system "CRTBNDRPG PGM($(BIN_LIB)/$*) SRCSTMF('/home/CLV/secrets/qrpglesrc/$*.rpgle') DBGVIEW(*ALL) OPTION(*EVENTF)"

%.sql:
	system -s "CHGATR OBJ('/home/CLV/secrets/qsqlsrc/$*.sql') ATR(*CCSID) VALUE(1252)"
	system -s "RUNSQLSTM SRCSTMF('/home/CLV/secrets/qsqlsrc/$*.sql') COMMIT(*NONE)"
