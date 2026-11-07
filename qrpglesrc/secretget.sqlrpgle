**free
// SECRETGET - Read a secret from table SECRETS and decrypt it.
//
// Usage:
//   CALL PGM(SECRETGET) PARM(1 'MyPassword')
//
// Parameters:
//   1. ID of the secret (a numeric literal on CALL arrives as packed 15,5)
//   2. Password used when the secret was encrypted (up to 32 characters)
//
// Db2 for i does NOT report an error when you decrypt with the wrong
// password: it returns garbage. SECRETADD stores the text with a fixed
// marker in front (MARKER), so a missing marker means a wrong password.

ctl-opt main(main);

dcl-c MARKER 'SECRET:';

dcl-proc main;
    dcl-pi *n;
        pId       packed(15:5);
        pPassword char(32);
    end-pi;

    dcl-s id       int(10);
    dcl-s password varchar(127);
    dcl-s text     varchar(256);  // garbage after a wrong password can be long
    dcl-s message  varchar(52);

    exec sql
        set option commit = *none;

    id       = %int(pId);
    password = %trim(pPassword);

    exec sql
        set encryption password = :password;
    if (sqlcode < 0);
        dsply ('SET ENCRYPTION PASSWORD failed: ' + sqlstate);
        return;
    endif;

    // DECRYPT_CHAR returns the original text in the job CCSID.
    // Use DECRYPT_BIT for binary data and DECRYPT_DB for DBCS/graphic data.
    // The algorithm (AES, TDES or RC2) is detected from the encrypted value.
    exec sql
        select decrypt_char(secret)
          into :text
          from secrets
         where id = :id;

    select;
        when (sqlcode = 100);
            dsply ('No secret found with ID ' + %char(id));
        when (sqlcode < 0);
            dsply ('SELECT failed: ' + sqlstate);
        when (%len(text) < %len(MARKER)
            or %subst(text: 1: %len(MARKER)) <> MARKER);
            // Decrypted, but it is garbage: the password does not match.
            dsply 'Wrong password.';
        other;
            // DSPLY shows up to 52 characters, so it goes through a
            // 52-character variable (the assignment truncates if needed).
            message = %subst(text: %len(MARKER) + 1);
            dsply message;
    endsl;

end-proc;
