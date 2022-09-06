BEGIN;

CREATE TABLE files (
    id VARCHAR(44) PRIMARY KEY CHECK(id ~ '^[a-zA-Z0-9_-]+$'),
    data BYTEA NOT NULL,
    uploaded TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    expiry TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW() + '30 days'
);

/* Disable default compression of data because we expect to always be given encrypted (and therefore
 * uncompressable) data: */
ALTER TABLE files ALTER COLUMN data SET STORAGE EXTERNAL;

CREATE INDEX files_expiry ON files(expiry);

CREATE TABLE release_versions (
    project varchar(50) PRIMARY KEY,
    version varchar(25) NOT NULL,
    updated TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Abritrary version values at the (approx) time this was written; this don't really matter as
-- they'll get updated within a first few seconds of initial startup.
INSERT INTO release_versions (project, version, updated) VALUES ('Beldex-Coin/bchat-desktop', 'v1.0.0', '2022-08-10Z');
INSERT INTO release_versions (project, version, updated) VALUES ('Beldex-Coin/bchat-android', '1.0.0', '2022-08-10Z');
INSERT INTO release_versions (project, version, updated) VALUES ('Beldex-Coin/bchat-ios', '1.0.0', '2022-08-10Z');

COMMIT;

-- vim:ft=sql
