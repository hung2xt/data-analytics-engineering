-- CI-only fixture: recreates the shape of the real fox_dwh.public.enriched_orders
-- table with small, synthetic data so dbt has something to build against
-- without ever touching the real warehouse. created_at is relative to now()
-- so `dbt source freshness` also passes in CI.

create table if not exists public.enriched_orders (
    order_id       varchar,
    customer_id    bigint,
    customer_name  varchar,
    email          varchar,
    city           varchar,
    tier           varchar,
    loyalty_points integer,
    product_id     varchar,
    product_name   varchar,
    quantity       integer,
    total_amount   double precision,
    created_at     timestamp without time zone
);

truncate table public.enriched_orders;

insert into public.enriched_orders
    (order_id, customer_id, customer_name, email, city, tier, loyalty_points, product_id, product_name, quantity, total_amount, created_at)
values
    ('CI-ORD-001', 2001, 'Ada Lovelace',   'ada@example.com',   'London',  'Platinum', 1200, 'P001', 'Laptop',     1,  1200, now() - interval '3 days'),
    ('CI-ORD-002', 2001, 'Ada Lovelace',   'ada@example.com',   'London',  'Platinum', 1250, 'P005', 'Headphones', 1,   150, now() - interval '2 days'),
    ('CI-ORD-003', 2002, 'Grace Hopper',   'grace@example.com', 'New York','Gold',      600, 'P004', 'Monitor',    2,   600, now() - interval '4 days'),
    ('CI-ORD-004', 2002, 'Grace Hopper',   'grace@example.com', 'New York','Gold',      650, 'P002', 'Mouse',      3,    75, now() - interval '1 days'),
    ('CI-ORD-005', 2003, 'Alan Turing',    'alan@example.com',  'Manchester','Silver',  300, 'P003', 'Keyboard',   1,    75, now() - interval '5 days'),
    ('CI-ORD-006', 2003, 'Alan Turing',    'alan@example.com',  'Manchester','Silver',  320, 'P001', 'Laptop',     1,  1200, now() - interval '2 days'),
    ('CI-ORD-007', 2004, 'Margaret Hamilton','margaret@example.com','Boston','Bronze',  100, 'P005', 'Headphones', 2,   300, now() - interval '6 days'),
    ('CI-ORD-008', 2004, 'Margaret Hamilton','margaret@example.com','Boston','Bronze',  110, 'P002', 'Mouse',      1,    25, now() - interval '1 days'),
    ('CI-ORD-009', 2005, 'Katherine Johnson','katherine@example.com','Hampton','Gold',  500, 'P004', 'Monitor',    1,   300, now() - interval '3 days'),
    ('CI-ORD-010', 2005, 'Katherine Johnson','katherine@example.com','Hampton','Gold',  520, 'P003', 'Keyboard',   2,   150, now() - interval '2 days'),
    ('CI-ORD-011', 2006, 'Radia Perlman',  'radia@example.com', 'Boston',  'Platinum', 900, 'P001', 'Laptop',     2,  2400, now() - interval '4 days'),
    ('CI-ORD-012', 2006, 'Radia Perlman',  'radia@example.com', 'Boston',  'Platinum', 950, 'P005', 'Headphones', 3,   450, now() - interval '1 days');
