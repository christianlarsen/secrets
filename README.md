# Encrypting data with Db2 for i SQL

Db2 for i can encrypt and decrypt column data with built-in SQL scalar
functions. You don't need extra products or APIs, only SQL. Many IBM i
shops don't know these functions exist, so this repository provides a small,
ready-to-build example you can try in a few minutes:

- an SQL script that walks through every step from *Run SQL Scripts*, and
- two SQLRPGLE programs that do the same from RPG.

## The functions

| Function | What it does |
| --- | --- |
| `SET ENCRYPTION PASSWORD` | Sets the default password (and optional hint) for the connection |
| `ENCRYPT_AES`, `ENCRYPT_TDES`, `ENCRYPT_RC2` | Encrypt a value with that algorithm |
| `DECRYPT_CHAR`, `DECRYPT_BIT`, `DECRYPT_DB`, `DECRYPT_BINARY` | Decrypt a value. Choose the function by the type of the *original* data. The algorithm is detected automatically. |
| `GETHINT` | Returns the password hint stored inside an encrypted value |

Things to know before you use them:

- Encrypted values are binary. The column that stores them must be
  `FOR BIT DATA`, `BINARY`/`VARBINARY` or `BLOB`.
- The encrypted value is longer than the original text. Size the column with
  the result length rules in the `ENCRYPT_AES` entry of the Db2 for i SQL
  Reference.
- Passwords are 6 to 127 characters long. Db2 does not store the password
  anywhere: if you lose it, the data cannot be recovered.
- **A wrong password does not raise an error.** `DECRYPT_CHAR` returns
  garbage instead. If you need to detect it, store a known marker with the
  data and check it after decrypting (the RPG examples do this).

## What's in the repo

```
qsqlsrc/secrets.sql             Creates the SECRETS table
qrpglesrc/secretadd.sqlrpgle    SECRETADD: encrypts a text and stores it
qrpglesrc/secretget.sqlrpgle    SECRETGET: reads and decrypts a secret
examples/encryption.sql         Step-by-step SQL walkthrough (not part of the build)
makefile                        Builds everything with GNU make
```

## Building

Requirements: IBM i 7.3 or later, plus `git` and GNU `make` from the IBM i
open source packages (`yum install git make-gnu`).

From a PASE shell (SSH) on your IBM i:

```sh
git clone https://github.com/christianlarsen/secrets.git
cd secrets
gmake BIN_LIB=MYLIB
```

`BIN_LIB` is the library that will hold the table and the programs. It is
created if it doesn't exist, and defaults to `SECRETS`. The table name is
not hard-coded to a library anywhere, so you can build the project into any
library.

### From VS Code (Code for IBM i)

Open the folder and run the **Deploy and build 🔨** action. It deploys the
sources to your IFS deploy directory and runs `gmake` with your current
library (`&CURLIB`) as `BIN_LIB`.

## Trying it

### From SQL

Open [`examples/encryption.sql`](examples/encryption.sql) in *Run SQL
Scripts* and run the statements one at a time.

### From RPG

```
CALL PGM(MYLIB/SECRETADD) PARM('This is a top secret!!' 'MyPassword')
  -> Secret stored with ID 1

CALL PGM(MYLIB/SECRETGET) PARM(1 'MyPassword')
  -> This is a top secret!!

CALL PGM(MYLIB/SECRETGET) PARM(1 'WrongPassword')
  -> Wrong password.
```

`SECRETADD` stores the text as `SECRET:` + your text. After decrypting,
`SECRETGET` checks that `SECRET:` is there: if it isn't, the password was
wrong and the result is garbage.

The programs pass the password in a host variable, never as an SQL literal,
so it doesn't show up in the plan cache. In these examples the text and the
password are limited to 32 characters to keep `CALL` from a command line
simple.

## Security notes

These are examples. Before you use this approach in production:

- **Don't hard-code passwords** in sources or pass them on a command line:
  a `CALL` with parameters is written to the job log. Read the password
  from somewhere protected, or ask the user for it.
- `SET ENCRYPTION PASSWORD` lasts for the connection (the job). Anything
  else that runs in that job can decrypt the data.
- Encryption protects the data at rest and in backups or copies. It does
  not replace object authority. Combine it with proper authorities, and look
  at **Row and Column Access Control (RCAC)** for masking, and at
  **FIELDPROC** for transparent column encryption.
