"""
Seed script — inserts one test user plus apartments/rooms/beds/tenants
mirroring the initApts fixture from the UI prototype.

Usage (from project root):
    python -m scripts.seed
"""

from __future__ import annotations

import asyncio
from datetime import datetime, timezone

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine

from app.config import get_settings
from app.models import Apartment, Base, Bed, RentPayment, Room, Tenant, User
from app.security import hash_password

# ── Seed data (mirrors initApts in remixed-b1b16beb.tsx) ──────────────────────

SEED_USER = {
    "name": "محمود",
    "email": "test@baitak.com",
    "password": "password123",
}

CURRENT_MONTH = "2026-03"


def dt(year: int, month: int) -> datetime:
    return datetime(year, month, 1, tzinfo=timezone.utc)


SEED_APTS = [
    {
        "name": "شقة الحديقة - مبنى ٣",
        "area": "الحي السادس",
        "address": "٢٤ شارع المحور، الحديقة",
        "floor": 2,
        "rooms": [
            {
                "name": "غرفة ١",
                "beds": [
                    {
                        "label": "سرير A",
                        "price": 1250,
                        "tenant": {
                            "name": "أحمد خالد",
                            "phone": "01012345678",
                            "since": dt(2025, 1),
                            "paid": True,
                        },
                    },
                    {
                        "label": "سرير B",
                        "price": 1250,
                        "tenant": {
                            "name": "سارة علي",
                            "phone": "01198765432",
                            "since": dt(2025, 2),
                            "paid": False,
                        },
                    },
                ],
            },
            {
                "name": "غرفة ٢",
                "beds": [
                    {
                        "label": "سرير A",
                        "price": 1300,
                        "tenant": {
                            "name": "محمد حسن",
                            "phone": "01555123456",
                            "since": dt(2024, 12),
                            "paid": True,
                        },
                    },
                    {"label": "سرير B", "price": 1300, "tenant": None},
                ],
            },
        ],
    },
    {
        "name": "ستوديو دريم لاند",
        "area": "دريم لاند",
        "address": "كمبوند دريم لاند، مبنى ٧، شقة ١٢",
        "floor": 3,
        "rooms": [
            {
                "name": "الغرفة الرئيسية",
                "beds": [
                    {"label": "سرير", "price": 3800, "tenant": None},
                ],
            },
        ],
    },
    {
        "name": "شقة المحور - ٤ غرف",
        "area": "المحور",
        "address": "شارع المحور الرئيسي، المحور المركزي",
        "floor": 1,
        "rooms": [
            {
                "name": "غرفة ١",
                "beds": [
                    {
                        "label": "سرير A",
                        "price": 1100,
                        "tenant": {
                            "name": "عمر إبراهيم",
                            "phone": "01233334444",
                            "since": dt(2025, 1),
                            "paid": True,
                        },
                    },
                    {"label": "سرير B", "price": 1100, "tenant": None},
                ],
            },
            {
                "name": "غرفة ٢",
                "beds": [
                    {
                        "label": "سرير A",
                        "price": 900,
                        "tenant": {
                            "name": "ياسمين فاروق",
                            "phone": "01066667777",
                            "since": dt(2025, 3),
                            "paid": True,
                        },
                    },
                    {"label": "سرير B", "price": 900, "tenant": None},
                    {"label": "سرير C", "price": 900, "tenant": None},
                ],
            },
        ],
    },
]


# ── Core seeding logic ─────────────────────────────────────────────────────────


async def seed(db: AsyncSession) -> None:
    # ── User ──────────────────────────────────────────────────────────────────
    existing = await db.execute(select(User).where(User.email == SEED_USER["email"]))
    user = existing.scalar_one_or_none()
    if user:
        print(f"User {SEED_USER['email']} already exists — skipping.")
        return

    user = User(
        name=SEED_USER["name"],
        email=SEED_USER["email"],
        hashed_password=hash_password(SEED_USER["password"]),
    )
    db.add(user)
    await db.flush()

    # ── Apartments, rooms, beds, tenants ──────────────────────────────────────
    for apt_data in SEED_APTS:
        apt = Apartment(
            owner_id=user.id,
            name=apt_data["name"],
            area=apt_data["area"],
            address=apt_data["address"],
            floor=apt_data["floor"],
        )
        db.add(apt)
        await db.flush()

        for room_idx, room_data in enumerate(apt_data["rooms"]):
            room = Room(
                apartment_id=apt.id,
                name=room_data["name"],
                order_index=room_idx,
            )
            db.add(room)
            await db.flush()

            for bed_data in room_data["beds"]:
                bed = Bed(
                    room_id=room.id,
                    label=bed_data["label"],
                    price_monthly=bed_data["price"],
                )
                db.add(bed)
                await db.flush()

                tenant_data = bed_data["tenant"]
                if tenant_data:
                    tenant = Tenant(
                        bed_id=bed.id,
                        name=tenant_data["name"],
                        phone=tenant_data["phone"],
                        start_date=tenant_data["since"],
                        active=True,
                    )
                    db.add(tenant)
                    await db.flush()

                    payment = RentPayment(
                        tenant_id=tenant.id,
                        month=CURRENT_MONTH,
                        amount=bed_data["price"],
                        status="paid" if tenant_data["paid"] else "unpaid",
                    )
                    db.add(payment)

    await db.commit()
    print("Seed complete.")
    print(f"  Login: {SEED_USER['email']} / {SEED_USER['password']}")


# ── Entry point ────────────────────────────────────────────────────────────────


async def main() -> None:
    settings = get_settings()
    engine = create_async_engine(settings.database_url, echo=False)
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    session_factory = async_sessionmaker(engine, expire_on_commit=False)
    async with session_factory() as db:
        await seed(db)
    await engine.dispose()


if __name__ == "__main__":
    asyncio.run(main())
