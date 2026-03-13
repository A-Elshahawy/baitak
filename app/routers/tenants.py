from __future__ import annotations

from collections.abc import Sequence
from decimal import Decimal

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import and_, func, select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from ..db import get_db
from ..deps import get_current_user
from ..models import Apartment, Bed, RentPayment, Room, Tenant, User
from ..schemas import (
    AssignTenantIn,
    MarkPaidIn,
    RentPaymentOut,
    TenantOut,
    TenantUpdate,
)

router = APIRouter()


async def _bed_with_owner_check(
    bed_id: int, user: User, db: AsyncSession
) -> Bed:
    result = await db.execute(
        select(Bed)
        .options(selectinload(Bed.room).selectinload(Room.apartment))
        .where(Bed.id == bed_id)
    )
    bed = result.scalar_one_or_none()
    if not bed:
        raise HTTPException(status_code=404, detail="Bed not found")
    if bed.room.apartment.owner_id != user.id:
        raise HTTPException(status_code=404, detail="Bed not found")
    return bed


@router.get("/", response_model=list[TenantOut])
async def list_tenants(
    unpaid_only: bool = False,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> Sequence[Tenant]:
    q = (
        select(Tenant)
        .join(Bed, Tenant.bed_id == Bed.id)
        .join(Room, Bed.room_id == Room.id)
        .join(Apartment, Room.apartment_id == Apartment.id)
        .where(and_(Apartment.owner_id == user.id, Tenant.active.is_(True)))
        .order_by(Tenant.id.desc())
    )
    if unpaid_only:
        # tenant has any unpaid payment
        q = q.join(RentPayment, RentPayment.tenant_id == Tenant.id).where(
            RentPayment.status == "unpaid"
        )
    res = await db.execute(q)
    return res.scalars().unique().all()


@router.post("/assign", response_model=TenantOut, status_code=status.HTTP_201_CREATED)
async def assign_tenant(
    payload: AssignTenantIn,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> Tenant:
    bed = await _bed_with_owner_check(payload.bed_id, user, db)
    if bed.tenant and bed.tenant.active:
        raise HTTPException(status_code=409, detail="Bed already occupied")

    tenant = Tenant(
        bed_id=bed.id,
        name=payload.name,
        phone=payload.phone,
        start_date=payload.start_date,
        active=True,
    )
    db.add(tenant)
    await db.flush()

    payment = RentPayment(
        tenant_id=tenant.id,
        month=payload.month,
        amount=payload.rent_amount,
        status="paid" if payload.mark_paid else "unpaid",
    )
    db.add(payment)
    await db.commit()
    await db.refresh(tenant)
    return tenant


@router.patch("/{tenant_id}", response_model=TenantOut)
async def update_tenant(
    tenant_id: int,
    payload: TenantUpdate,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> Tenant:
    result = await db.execute(
        select(Tenant)
        .options(selectinload(Tenant.bed).selectinload(Bed.room).selectinload(Room.apartment))
        .where(Tenant.id == tenant_id)
    )
    tenant = result.scalar_one_or_none()
    if not tenant or not tenant.bed or tenant.bed.room.apartment.owner_id != user.id:
        raise HTTPException(status_code=404, detail="Tenant not found")

    for field, value in payload.model_dump(exclude_unset=True).items():
        setattr(tenant, field, value)

    await db.commit()
    await db.refresh(tenant)
    return tenant


@router.post("/{tenant_id}/vacate", status_code=status.HTTP_204_NO_CONTENT, response_model=None)
async def vacate_tenant(
    tenant_id: int,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> None:
    result = await db.execute(
        select(Tenant)
        .options(selectinload(Tenant.bed).selectinload(Bed.room).selectinload(Room.apartment))
        .where(Tenant.id == tenant_id)
    )
    tenant = result.scalar_one_or_none()
    if not tenant or not tenant.bed or tenant.bed.room.apartment.owner_id != user.id:
        raise HTTPException(status_code=404, detail="Tenant not found")

    tenant.active = False
    tenant.bed_id = None
    await db.commit()


@router.get("/{tenant_id}/payments", response_model=list[RentPaymentOut])
async def list_payments(
    tenant_id: int,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> Sequence[RentPayment]:
    # owner check via join path
    q = (
        select(RentPayment)
        .join(Tenant, RentPayment.tenant_id == Tenant.id)
        .join(Bed, Tenant.bed_id == Bed.id, isouter=True)
        .join(Room, Bed.room_id == Room.id, isouter=True)
        .join(Apartment, Room.apartment_id == Apartment.id, isouter=True)
        .where(and_(Tenant.id == tenant_id, Apartment.owner_id == user.id))
        .order_by(RentPayment.month.desc())
    )
    res = await db.execute(q)
    return res.scalars().all()


@router.post("/{tenant_id}/payments/mark-paid", response_model=RentPaymentOut)
async def mark_paid(
    tenant_id: int,
    payload: MarkPaidIn,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> RentPayment:
    # ensure tenant belongs to user
    owner_check = await db.execute(
        select(func.count())
        .select_from(Tenant)
        .join(Bed, Tenant.bed_id == Bed.id, isouter=True)
        .join(Room, Bed.room_id == Room.id, isouter=True)
        .join(Apartment, Room.apartment_id == Apartment.id, isouter=True)
        .where(and_(Tenant.id == tenant_id, Apartment.owner_id == user.id))
    )
    if (owner_check.scalar_one() or 0) == 0:
        raise HTTPException(status_code=404, detail="Tenant not found")

    res = await db.execute(
        select(RentPayment).where(
            and_(RentPayment.tenant_id == tenant_id, RentPayment.month == payload.month)
        )
    )
    payment = res.scalar_one_or_none()
    if not payment:
        # create if missing
        payment = RentPayment(
            tenant_id=tenant_id,
            month=payload.month,
            amount=Decimal(str(payload.amount or 0)),
            status="paid",
        )
        db.add(payment)
    else:
        payment.status = "paid"
        if payload.amount is not None:
            payment.amount = Decimal(str(payload.amount))

    await db.commit()
    await db.refresh(payment)
    return payment

