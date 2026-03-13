from __future__ import annotations

from fastapi import APIRouter, Depends
from sqlalchemy import and_, func, select
from sqlalchemy.ext.asyncio import AsyncSession

from ..db import get_db
from ..deps import get_current_user
from ..models import Apartment, Bed, RentPayment, Room, Tenant, User
from ..schemas import ApartmentStatsOut, OverviewOut

router = APIRouter()


@router.get("/overview", response_model=OverviewOut)
async def overview(
    user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)
) -> OverviewOut:
    apartments_count = await db.execute(
        select(func.count()).select_from(Apartment).where(Apartment.owner_id == user.id)
    )
    beds_total = await db.execute(
        select(func.count())
        .select_from(Bed)
        .join(Room, Bed.room_id == Room.id)
        .join(Apartment, Room.apartment_id == Apartment.id)
        .where(Apartment.owner_id == user.id)
    )
    beds_occupied = await db.execute(
        select(func.count())
        .select_from(Bed)
        .join(Room, Bed.room_id == Room.id)
        .join(Apartment, Room.apartment_id == Apartment.id)
        .join(Tenant, and_(Tenant.bed_id == Bed.id, Tenant.active.is_(True)))
        .where(Apartment.owner_id == user.id)
    )
    # Monthly revenue = sum of bed prices for all currently occupied beds
    revenue = await db.execute(
        select(func.coalesce(func.sum(Bed.price_monthly), 0))
        .select_from(Bed)
        .join(Room, Bed.room_id == Room.id)
        .join(Apartment, Room.apartment_id == Apartment.id)
        .join(Tenant, and_(Tenant.bed_id == Bed.id, Tenant.active.is_(True)))
        .where(Apartment.owner_id == user.id)
    )
    # Unpaid count = distinct active tenants who have at least one unpaid payment
    unpaid_count = await db.execute(
        select(func.count(func.distinct(Tenant.id)))
        .select_from(Tenant)
        .join(Bed, Tenant.bed_id == Bed.id)
        .join(Room, Bed.room_id == Room.id)
        .join(Apartment, Room.apartment_id == Apartment.id)
        .join(RentPayment, RentPayment.tenant_id == Tenant.id)
        .where(
            and_(
                Apartment.owner_id == user.id,
                Tenant.active.is_(True),
                RentPayment.status == "unpaid",
            )
        )
    )

    t = int(beds_total.scalar_one() or 0)
    o = int(beds_occupied.scalar_one() or 0)
    return OverviewOut(
        apartments=int(apartments_count.scalar_one() or 0),
        beds_total=t,
        beds_occupied=o,
        beds_vacant=t - o,
        revenue_monthly=float(revenue.scalar_one() or 0),
        unpaid_count=int(unpaid_count.scalar_one() or 0),
    )


@router.get("/apartments", response_model=list[ApartmentStatsOut])
async def apartments_stats(
    user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)
) -> list[ApartmentStatsOut]:
    rows = await db.execute(
        select(
            Apartment.id,
            Apartment.name,
            func.count(Bed.id).label("beds_total"),
            func.count(Tenant.id).label("beds_occupied"),
            # Revenue = sum of price_monthly only for occupied beds
            func.coalesce(
                func.sum(Bed.price_monthly).filter(Tenant.id.is_not(None)), 0
            ).label("revenue_monthly"),
        )
        .join(Room, Room.apartment_id == Apartment.id, isouter=True)
        .join(Bed, Bed.room_id == Room.id, isouter=True)
        .join(
            Tenant,
            and_(Tenant.bed_id == Bed.id, Tenant.active.is_(True)),
            isouter=True,
        )
        .where(Apartment.owner_id == user.id)
        .group_by(Apartment.id, Apartment.name)
        .order_by(Apartment.id)
    )
    return [
        ApartmentStatsOut(
            id=apt_id,
            name=name,
            beds_total=int(beds_total or 0),
            beds_occupied=int(beds_occupied or 0),
            revenue_monthly=float(revenue_monthly or 0),
        )
        for apt_id, name, beds_total, beds_occupied, revenue_monthly in rows.all()
    ]
