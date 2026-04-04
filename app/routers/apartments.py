from collections.abc import Sequence

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from ..db import get_db
from ..deps import get_current_user
from ..models import Apartment, Bed, RentPayment, Room, Tenant, User
from ..schemas import ApartmentCreate, ApartmentOut, ApartmentUpdate

router = APIRouter()


@router.get("", response_model=list[ApartmentOut])
async def list_apartments(
    user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)
) -> Sequence[Apartment]:
    result = await db.execute(
        select(Apartment)
        .options(
            selectinload(Apartment.rooms)
            .selectinload(Room.beds)
            .selectinload(Bed.tenant)
            .selectinload(Tenant.payments)
        )
        .where(Apartment.owner_id == user.id)
        .order_by(Apartment.id)
    )
    return result.scalars().unique().all()


@router.post("", response_model=ApartmentOut, status_code=status.HTTP_201_CREATED)
async def create_apartment(
    payload: ApartmentCreate,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> Apartment:
    ap = Apartment(
        owner_id=user.id,
        name=payload.name,
        area=payload.area,
        address=payload.address,
        floor=payload.floor,
    )
    db.add(ap)
    await db.commit()
    result = await db.execute(
        select(Apartment)
        .options(
            selectinload(Apartment.rooms)
            .selectinload(Room.beds)
            .selectinload(Bed.tenant)
            .selectinload(Tenant.payments)
        )
        .where(Apartment.id == ap.id)
    )
    return result.scalar_one()


@router.get("/{apartment_id}", response_model=ApartmentOut)
async def get_apartment(
    apartment_id: int,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> Apartment:
    result = await db.execute(
        select(Apartment)
        .options(
            selectinload(Apartment.rooms)
            .selectinload(Room.beds)
            .selectinload(Bed.tenant)
            .selectinload(Tenant.payments)
        )
        .where(Apartment.id == apartment_id)
    )
    ap = result.scalar_one_or_none()
    if not ap or ap.owner_id != user.id:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Not found")
    return ap


@router.patch("/{apartment_id}", response_model=ApartmentOut)
async def update_apartment(
    apartment_id: int,
    payload: ApartmentUpdate,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> Apartment:
    ap = await db.get(Apartment, apartment_id)
    if not ap or ap.owner_id != user.id:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Not found")

    for field, value in payload.model_dump(exclude_unset=True).items():
        setattr(ap, field, value)

    await db.commit()
    result = await db.execute(
        select(Apartment)
        .options(
            selectinload(Apartment.rooms)
            .selectinload(Room.beds)
            .selectinload(Bed.tenant)
            .selectinload(Tenant.payments)
        )
        .where(Apartment.id == ap.id)
    )
    return result.scalar_one()


@router.delete("/{apartment_id}", status_code=status.HTTP_204_NO_CONTENT, response_model=None)
async def delete_apartment(
    apartment_id: int,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> None:
    ap = await db.get(Apartment, apartment_id)
    if not ap or ap.owner_id != user.id:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Not found")
    await db.delete(ap)
    await db.commit()
