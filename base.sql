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

CREATE TABLE IF NOT EXISTS upgrade
(
  uid SERIAL PRIMARY KEY NOT NULL,
  name VARCHAR(128) NOT NULL,
  cost INT NOT NULL,
  type INT NOT NULL,
  modificator INT NOT NULL,
  image VARCHAR(128),
  time INT
);

CREATE UNIQUE INDEX game_name_uindex ON public.game (name);