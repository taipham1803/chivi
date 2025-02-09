-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
CREATE TABLE dboards (
  id bigserial primary key, -- match with cvbook id

  bname text not null, -- board name
  bslug text unique not null, -- board unique slug

  posts int not null default '0', -- topic count
  views int not null default '0', -- click count

  created_at timestamptz not null default CURRENT_TIMESTAMP,
  updated_at timestamptz not null default CURRENT_TIMESTAMP
);

CREATE UNIQUE INDEX dboard_bslug_idx ON dboards (bslug);

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
DROP TABLE IF EXISTS dboards;