"""
Creates a new schema `policy_admin` in fox_dwh and populates it with
synthetic life-insurance policy admin data (t_customer, t_agent, t_product,
t_policy, t_premium_payment, t_rider) — stands in for a real Policy
Administration System (PAS) that would normally feed a warehouse via CDC/ETL.

This is a SOURCE schema: dbt only ever reads from it via source(), never
writes to it. Transformation output goes to schema `analytical_engineer`
(see dbt/fox_analytics).

Usage:
    python3 scripts/generate_policy_admin_source.py
"""

import datetime
import os
import random

import psycopg2

random.seed(42)

DB_HOST = os.environ.get("DW_HOST", "127.0.0.1")
DB_PORT = os.environ.get("DW_PORT", "5432")
DB_USER = os.environ.get("DW_USER")
DB_PASSWORD = os.environ.get("DW_PASSWORD")
DB_NAME = os.environ.get("DW_DB")

if not (DB_USER and DB_PASSWORD and DB_NAME):
    raise SystemExit(
        "Set DW_USER, DW_PASSWORD and DW_DB (see .env.example) before running this script."
    )

TODAY = datetime.date(2026, 9, 13)

FIRST_NAMES = [
    "Minh", "Linh", "Hoa", "Nam", "Thao", "Duc", "Huong", "Long", "Mai", "Tuan",
    "Anh", "Bao", "Chi", "Dung", "Giang", "Hanh", "Khang", "Lam", "Ngoc", "Phong",
]
LAST_NAMES = ["Nguyen", "Tran", "Le", "Pham", "Hoang", "Phan", "Vu", "Vo", "Dang", "Bui"]
CITIES = ["Ho Chi Minh City", "Hanoi", "Da Nang", "Can Tho", "Hai Phong", "Nha Trang"]

PRODUCTS = [
    ("TRM10", "Term Life 10Y", "TERM", 10, 200_000_000),
    ("TRM20", "Term Life 20Y", "TERM", 20, 300_000_000),
    ("WL01", "Whole Life Secure", "WHOLE_LIFE", 20, 500_000_000),
    ("WL02", "Whole Life Plus", "WHOLE_LIFE", 15, 400_000_000),
    ("END15", "Endowment Save 15Y", "ENDOWMENT", 15, 300_000_000),
    ("END20", "Endowment Save 20Y", "ENDOWMENT", 20, 400_000_000),
    ("UL01", "Unit-Linked Growth", "UNIT_LINKED", 10, 250_000_000),
    ("UL02", "Unit-Linked Flexi", "UNIT_LINKED", 15, 350_000_000),
    ("CI01", "Critical Illness Shield", "CRITICAL_ILLNESS", 10, 200_000_000),
    ("CI02", "Critical Illness Plus", "CRITICAL_ILLNESS", 15, 300_000_000),
]

RIDER_TYPES = [
    ("ACCIDENTAL_DEATH", 0.05),
    ("CRITICAL_ILLNESS", 0.10),
    ("WAIVER_OF_PREMIUM", 0.03),
    ("HOSPITAL_CASH", 0.02),
    ("DISABILITY_INCOME", 0.04),
]

PREMIUM_FREQUENCIES = {
    "MONTHLY": 1,
    "QUARTERLY": 3,
    "SEMI_ANNUAL": 6,
    "ANNUAL": 12,
}

POLICY_STATUS_WEIGHTS = [
    ("ACTIVE", 0.55),
    ("LAPSED", 0.20),
    ("SURRENDERED", 0.10),
    ("MATURED", 0.05),
    ("DEATH_CLAIM", 0.05),
    ("PENDING", 0.05),
]


def weighted_choice(pairs):
    r = random.random()
    cum = 0.0
    for value, weight in pairs:
        cum += weight
        if r <= cum:
            return value
    return pairs[-1][0]


def random_date(start: datetime.date, end: datetime.date) -> datetime.date:
    delta = (end - start).days
    return start + datetime.timedelta(days=random.randint(0, max(delta, 0)))


def months_between(start: datetime.date, end: datetime.date) -> int:
    return max(0, (end.year - start.year) * 12 + (end.month - start.month))


def build_customers(n=40):
    rows = []
    for i in range(1, n + 1):
        name = f"{random.choice(LAST_NAMES)} {random.choice(FIRST_NAMES)}"
        dob = random_date(datetime.date(1965, 1, 1), datetime.date(2000, 12, 31))
        gender = random.choice(["M", "F"])
        city = random.choice(CITIES)
        phone = f"09{random.randint(10000000, 99999999)}"
        email = f"customer{i}@example.com"
        occupation_class = weighted_choice([("A", 0.6), ("B", 0.3), ("C", 0.1)])
        created_at = random_date(datetime.date(2018, 1, 1), datetime.date(2020, 1, 1))
        rows.append((i, name, dob, gender, city, phone, email, occupation_class, created_at))
    return rows


def build_agents(n=8):
    rows = []
    for i in range(1, n + 1):
        name = f"{random.choice(LAST_NAMES)} {random.choice(FIRST_NAMES)}"
        region = random.choice(["North", "Central", "South"])
        hire_date = random_date(datetime.date(2015, 1, 1), datetime.date(2023, 1, 1))
        status = weighted_choice([("ACTIVE", 0.85), ("INACTIVE", 0.15)])
        rows.append((i, name, region, hire_date, status))
    return rows


def build_policies(customers, agents, n=80):
    rows = []
    for i in range(1, n + 1):
        customer_id = random.choice(customers)[0]
        agent_id = random.choice(agents)[0]
        product = random.choice(PRODUCTS)
        product_code = product[0]
        issue_date = random_date(datetime.date(2019, 1, 1), datetime.date(2026, 6, 1))
        policy_status = weighted_choice(POLICY_STATUS_WEIGHTS)
        premium_frequency = random.choice(list(PREMIUM_FREQUENCIES))
        annual_premium = round(random.uniform(6_000_000, 40_000_000), -3)
        sum_assured = product[4] * random.choice([1, 1, 1.5, 2])

        lapse_date = None
        if policy_status == "LAPSED":
            min_lapse = issue_date + datetime.timedelta(days=90)
            lapse_date = random_date(min_lapse, min(TODAY, issue_date + datetime.timedelta(days=365 * 5)))

        updated_at = datetime.datetime.combine(
            lapse_date or TODAY, datetime.time(random.randint(8, 18), random.randint(0, 59))
        )

        rows.append(
            (
                i,
                f"POL-{100000 + i}",
                customer_id,
                agent_id,
                product_code,
                issue_date,
                policy_status,
                premium_frequency,
                annual_premium,
                sum_assured,
                lapse_date,
                updated_at,
            )
        )
    return rows


def build_premium_payments(policies):
    rows = []
    payment_id = 1
    for policy in policies:
        (
            policy_id,
            _policy_number,
            _customer_id,
            _agent_id,
            _product_code,
            issue_date,
            policy_status,
            premium_frequency,
            annual_premium,
            _sum_assured,
            lapse_date,
            _updated_at,
        ) = policy

        end_date = lapse_date if policy_status == "LAPSED" else TODAY
        months_active = months_between(issue_date, end_date)
        interval_months = PREMIUM_FREQUENCIES[premium_frequency]
        installment_amount = round(annual_premium * interval_months / 12, -3)

        n_installments = max(0, months_active // interval_months)
        due_date = issue_date
        for _ in range(n_installments):
            due_date = due_date + datetime.timedelta(days=30 * interval_months)
            if due_date > end_date:
                break

            if policy_status == "LAPSED" and due_date > (lapse_date - datetime.timedelta(days=30)):
                # the missed payment(s) right before lapsing
                status = "MISSED"
                paid_date = None
                amount_paid = 0
            else:
                status = weighted_choice([("PAID", 0.92), ("PARTIAL", 0.05), ("MISSED", 0.03)])
                if status == "PAID":
                    paid_date = due_date + datetime.timedelta(days=random.randint(-3, 10))
                    amount_paid = installment_amount
                elif status == "PARTIAL":
                    paid_date = due_date + datetime.timedelta(days=random.randint(0, 15))
                    amount_paid = round(installment_amount * random.uniform(0.3, 0.8), -3)
                else:
                    paid_date = None
                    amount_paid = 0

            rows.append(
                (payment_id, policy_id, due_date, paid_date, installment_amount, amount_paid, status)
            )
            payment_id += 1
    return rows


def build_riders(policies):
    rows = []
    rider_id = 1
    for policy in policies:
        policy_id = policy[0]
        issue_date = policy[5]
        policy_status = policy[6]
        for rider_type, prob in RIDER_TYPES:
            if random.random() < prob * 4:  # a bit more common, keeps volume reasonable
                policy_ended = policy_status in ("LAPSED", "SURRENDERED")
                rider_status = "CANCELLED" if policy_ended and random.random() < 0.5 else "ACTIVE"
                rider_premium = round(random.uniform(300_000, 3_000_000), -3)
                sum_assured_rider = round(random.uniform(50_000_000, 200_000_000), -6)
                rows.append(
                    (rider_id, policy_id, rider_type, rider_premium, sum_assured_rider, rider_status, issue_date)
                )
                rider_id += 1
    return rows


DDL = """
create schema if not exists policy_admin;

drop table if exists policy_admin.t_rider;
drop table if exists policy_admin.t_premium_payment;
drop table if exists policy_admin.t_policy;
drop table if exists policy_admin.t_product;
drop table if exists policy_admin.t_agent;
drop table if exists policy_admin.t_customer;

create table policy_admin.t_customer (
    customer_id      integer primary key,
    full_name        text,
    dob              date,
    gender           char(1),
    city             text,
    phone            text,
    email            text,
    occupation_class text,
    created_at       date
);

create table policy_admin.t_agent (
    agent_id     integer primary key,
    full_name    text,
    region       text,
    hire_date    date,
    agent_status text
);

create table policy_admin.t_product (
    product_code      text primary key,
    product_name      text,
    product_type      text,
    premium_term_years integer,
    min_sum_assured   numeric
);

create table policy_admin.t_policy (
    policy_id         integer primary key,
    policy_number     text,
    customer_id       integer references policy_admin.t_customer(customer_id),
    agent_id          integer references policy_admin.t_agent(agent_id),
    product_code      text references policy_admin.t_product(product_code),
    issue_date        date,
    policy_status     text,
    premium_frequency text,
    annual_premium    numeric,
    sum_assured       numeric,
    lapse_date        date,
    updated_at        timestamp
);

create table policy_admin.t_premium_payment (
    payment_id     integer primary key,
    policy_id      integer references policy_admin.t_policy(policy_id),
    due_date       date,
    paid_date      date,
    amount_due     numeric,
    amount_paid    numeric,
    payment_status text
);

create table policy_admin.t_rider (
    rider_id           integer primary key,
    policy_id          integer references policy_admin.t_policy(policy_id),
    rider_type         text,
    rider_premium      numeric,
    sum_assured_rider  numeric,
    rider_status       text,
    effective_date     date
);
"""


def main():
    conn = psycopg2.connect(
        host=DB_HOST, port=DB_PORT, user=DB_USER, password=DB_PASSWORD, dbname=DB_NAME
    )
    conn.autocommit = False
    cur = conn.cursor()

    cur.execute(DDL)

    customers = build_customers()
    agents = build_agents()
    policies = build_policies(customers, agents)
    payments = build_premium_payments(policies)
    riders = build_riders(policies)

    cur.executemany(
        "insert into policy_admin.t_customer values (%s,%s,%s,%s,%s,%s,%s,%s,%s)", customers
    )
    cur.executemany("insert into policy_admin.t_agent values (%s,%s,%s,%s,%s)", agents)
    cur.executemany("insert into policy_admin.t_product values (%s,%s,%s,%s,%s)", PRODUCTS)
    cur.executemany(
        "insert into policy_admin.t_policy values (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)", policies
    )
    cur.executemany(
        "insert into policy_admin.t_premium_payment values (%s,%s,%s,%s,%s,%s,%s)", payments
    )
    cur.executemany("insert into policy_admin.t_rider values (%s,%s,%s,%s,%s,%s,%s)", riders)

    conn.commit()

    print(f"customers:        {len(customers)}")
    print(f"agents:           {len(agents)}")
    print(f"products:         {len(PRODUCTS)}")
    print(f"policies:         {len(policies)}")
    print(f"premium_payments: {len(payments)}")
    print(f"riders:           {len(riders)}")

    cur.close()
    conn.close()


if __name__ == "__main__":
    main()
