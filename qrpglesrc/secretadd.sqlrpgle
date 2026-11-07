**free
// SECRETADD - Encrypt a text with AES and store it in table SECRETS.
//
// Usage:
//   CALL PGM(SECRETADD) PARM('This is a top secret!!' 'MyPassword')
//
// Parameters (both up to 32 characters, trailing blanks are ignored):
//   1. Text to encrypt
//   2. Encryption password (6 to 127 characters, 32 max in this example)
//
// The password used here is the one you will need to decrypt the value
// with SECRETGET. Db2 does not keep it anywhere: if you lose it, the data
// cannot be recovered.
//
// Db2 for i does NOT report an error when you decrypt with the wrong
// password: it returns garbage. To detect that, the text is stored with a
// fixed marker in front (MARKER). SECRETGET checks that the marker is there
// after decrypting.

ctl-opt main(main);

dcl-c MARKER 'SECRET:';

dcl-proc main;
    dcl-pi *n;
        pText     char(32);
        pPassword char(32);
    end-pi;

    dcl-s text     varchar(39);   // MARKER + up to 32 characters
    dcl-s password varchar(127);
    dcl-s newId    int(10);

    exec sql
        set option commit = *none;

    text     = MARKER + %trim(pText);
    password = %trim(pPassword);

    if (%len(text) = %len(MARKER));
        dsply 'The text to encrypt is empty.';
        return;
    endif;

    if (%len(password) < 6);
        dsply 'The password needs at least 6 characters.';
        return;
    endif;

    // The password is passed in a host variable, never as a literal, so it
    // does not show up in the SQL plan cache or in database monitor output.
    // It stays active for the rest of the job (connection).
    exec sql
        set encryption password = :password;
    if (sqlcode < 0);
        dsply ('SET ENCRYPTION PASSWORD failed: ' + sqlstate);
        return;
    endif;

    // ENCRYPT_AES uses the password set above. ENCRYPT_TDES and ENCRYPT_RC2
    // work the same way if you need another algorithm.
    exec sql
        insert into secrets (secret)
            values (encrypt_aes(:text));
    if (sqlcode < 0);
        dsply ('INSERT failed: ' + sqlstate);
        return;
    endif;

    exec sql
        values identity_val_local() into :newId;

    dsply ('Secret stored with ID ' + %char(newId));

end-proc;
