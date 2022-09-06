CREATE DATABASE refapp;

\c refapp

CREATE TABLE records(
   ID SERIAL PRIMARY KEY,
   created_at     timestamp  NOT NULL,
   data           CHAR(255),
   host           CHAR(255)  NOT NULL
);

do $$
begin
for r in 1..10 loop
INSERT INTO records (data, host, created_at) values ('test', 'prefill', now());
end loop;
end;
$$;
