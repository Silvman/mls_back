CREATE TABLE IF NOT EXISTS "user"
(
  uid      SERIAL       NOT NULL
    CONSTRAINT users_pkey
    PRIMARY KEY,
  username text  NOT NULL,
  email    text,
  pass     text NOT NULL,
  score    INTEGER DEFAULT 0
);

CREATE UNIQUE INDEX users_uid_uindex
  ON "user" (uid);

CREATE UNIQUE INDEX users_username_uindex
  ON "user" (username);