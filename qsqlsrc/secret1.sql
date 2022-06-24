create or replace table clv1.secret1 (
    id numeric(5) not null generated always as identity (start with 1, increment by 1),
    description varchar(128) for bit data,
    primary key(id) 
)
rcdfmt rsecret1;

label on table clv1.secret1 is 'Top secret information';

label on column clv1.secret1 (
    id          is 'Secret ID',
    description is 'Secret content'
);