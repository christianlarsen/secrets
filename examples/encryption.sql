-- Db2 for i column encryption, step by step.
--
-- Run these statements one at a time from "Run SQL Scripts" (IBM i Access
-- Client Solutions) or from Code for IBM i. They use the SECRETS table
-- created by `gmake` (qsqlsrc/secrets.sql).
--
-- Literal passwords are fine for trying things out, but a literal can end
-- up in the SQL plan cache and in database monitor output. In real
-- programs, pass the password in a host variable or parameter marker.

-- 1. Point to the library where you built the project.
set schema secrets;

-- 2. Set the password (and an optional hint) for this connection.
--    Every ENCRYPT_* / DECRYPT_* call that does not receive a password
--    explicitly uses this one, until the connection ends or it changes.
set encryption password = 'MyPassword' with hint = 'The usual one';

-- 3. Encrypt and store some data. ENCRYPT_TDES and ENCRYPT_RC2 work the
--    same way.
insert into secrets (secret) values (encrypt_aes('My PIN is 1234'));
insert into secrets (secret) values (encrypt_aes('Card 4111 1111 1111 1111'));

-- 4. What is stored on disk: unreadable binary data.
select id, secret, created_at from secrets;

-- 5. Decrypt it with the password that is set.
select id, decrypt_char(secret) as secret, created_at from secrets;

-- 6. Forgot the password? GETHINT returns the hint stored with the value.
select id, gethint(secret) as hint from secrets;

-- 7. Careful: with the wrong password there is NO error. Db2 for i
--    "decrypts" anyway and returns garbage.
set encryption password = 'WrongPassword';
select id, decrypt_char(secret) from secrets;

-- 8. You can also pass the password directly to each function. The
--    explicit password takes precedence over SET ENCRYPTION PASSWORD.
select id, decrypt_char(secret, 'MyPassword') as secret from secrets;

-- 9. To detect a wrong password, store the text with a fixed marker in
--    front and check it after decrypting. This is what SECRETADD and
--    SECRETGET do with the marker 'SECRET:'.
insert into secrets (secret)
    values (encrypt_aes('SECRET:' concat 'My PIN is 1234', 'MyPassword'));

select id,
       case when decrypt_char(secret, 'WrongPassword') like 'SECRET:%'
            then substr(decrypt_char(secret, 'WrongPassword'), 8)
            else '*** wrong password ***'
       end as secret
  from secrets;
