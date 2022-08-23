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



COMMIT;

-- vim:ft=sql
