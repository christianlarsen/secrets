**free
ctl-opt main(main);

// Adding secrets to my table

dcl-proc main;

    dcl-s #pass char(30) inz('Password');
    dcl-s #what char(30);

    exec sql
        set option commit = *none;

    exec sql
        set encryption password :#pass;

    // In this case I'm using AES codification, but I can use either RC2 or TDES...
    exec sql
        insert into clv1.secret1 values (
            default,
            encrypt_aes('This is a top secret!!', 'Password')
        );

end-proc;