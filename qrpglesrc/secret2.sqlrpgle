**free
ctl-opt main(main);

// Retrieving secrets from my table...

dcl-proc main;

    dcl-s #pass char(30) inz('Password');
    dcl-s #what char(30);

    exec sql
        set option commit = *none;

    exec sql
        set encryption password :#pass;

    // With decrypt_bit  is enough .. the system knows about the codification...
    // but it important to set the field "for bit data" ...if not, it cannot be 
    // decrypted...
    exec sql
        select decrypt_bit(description) into :#what
        from clv1.secret1
        where id = 1;

    dsply #what;

end-proc;