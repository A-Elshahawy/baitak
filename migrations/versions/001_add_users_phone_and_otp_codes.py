"""add users.phone and otp_codes table

Revision ID: 001
Revises:
Create Date: 2026-04-04
"""
import sqlalchemy as sa
from alembic import op

revision = "001"
down_revision = None
branch_labels = None
depends_on = None


def upgrade() -> None:
    bind = op.get_bind()
    dialect = bind.dialect.name
    inspector = sa.inspect(bind)

    if dialect == "postgresql":
        # PostgreSQL supports IF NOT EXISTS — safe to run on an already-migrated DB.
        bind.execute(sa.text(
            "ALTER TABLE users ADD COLUMN IF NOT EXISTS phone VARCHAR(20)"
        ))
        bind.execute(sa.text(
            "CREATE UNIQUE INDEX IF NOT EXISTS ix_users_phone ON users (phone) "
            "WHERE phone IS NOT NULL"
        ))
        bind.execute(sa.text("""
            CREATE TABLE IF NOT EXISTS otp_codes (
                id          SERIAL      PRIMARY KEY,
                phone       VARCHAR(20) NOT NULL,
                code        VARCHAR(6)  NOT NULL,
                expires_at  TIMESTAMPTZ NOT NULL,
                used        BOOLEAN     NOT NULL DEFAULT FALSE,
                created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
                updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
            )
        """))
        bind.execute(sa.text(
            "CREATE INDEX IF NOT EXISTS ix_otp_codes_phone ON otp_codes (phone)"
        ))

    else:
        # SQLite (local dev): use Alembic ops with existence checks.
        user_cols = {c["name"] for c in inspector.get_columns("users")}
        if "phone" not in user_cols:
            op.add_column("users", sa.Column("phone", sa.String(20), nullable=True))
            op.create_index("ix_users_phone", "users", ["phone"], unique=True)

        if "otp_codes" not in inspector.get_table_names():
            op.create_table(
                "otp_codes",
                sa.Column("id", sa.Integer, primary_key=True, autoincrement=True),
                sa.Column("phone", sa.String(20), nullable=False),
                sa.Column("code", sa.String(6), nullable=False),
                sa.Column("expires_at", sa.DateTime(timezone=True), nullable=False),
                sa.Column("used", sa.Boolean, nullable=False, server_default=sa.false()),
                sa.Column("created_at", sa.DateTime(timezone=True), nullable=False,
                           server_default=sa.func.now()),
                sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False,
                           server_default=sa.func.now()),
            )
            op.create_index("ix_otp_codes_phone", "otp_codes", ["phone"])


def downgrade() -> None:
    bind = op.get_bind()
    dialect = bind.dialect.name

    if dialect == "postgresql":
        bind.execute(sa.text("DROP TABLE IF EXISTS otp_codes"))
        bind.execute(sa.text("ALTER TABLE users DROP COLUMN IF EXISTS phone"))
    else:
        inspector = sa.inspect(bind)
        if "otp_codes" in inspector.get_table_names():
            op.drop_table("otp_codes")
        user_cols = {c["name"] for c in inspector.get_columns("users")}
        if "phone" in user_cols:
            with op.batch_alter_table("users") as batch_op:
                batch_op.drop_column("phone")
