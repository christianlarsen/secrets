-- Table that stores encrypted values.
--
-- The table name is unqualified: the makefile runs this script with
-- DFTRDBCOL(<your library>), so it is created wherever you build the project.
--
-- Encrypted values MUST be stored in a binary column (FOR BIT DATA,
-- BINARY/VARBINARY or BLOB). The encrypted value is longer than the
-- original text: check the result length rules of ENCRYPT_AES in the
-- Db2 for i SQL Reference before sizing the column for your own data.
--
-- On Db2 for i, CREATE OR REPLACE TABLE keeps the existing rows by default
-- (ON REPLACE PRESERVE ALL ROWS), so rebuilding does not lose data.

create or replace table secrets (
    id         integer       not null generated always as identity
                             (start with 1, increment by 1),
    secret     varchar(256)  for bit data not null,
    created_at timestamp     not null default current timestamp,
    primary key (id)
)
rcdfmt secretsr;

label on table secrets is 'Encrypted secrets (Db2 for i examples)';

label on column secrets (
    id         is 'Secret ID',
    secret     is 'Encrypted value',
    created_at is 'Created at'
);
