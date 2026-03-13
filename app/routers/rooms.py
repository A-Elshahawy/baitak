from __future__ import annotations

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from ..db import get_db
from ..deps import get_current_user
from ..models import Apartment, Bed, Room, User
from ..schemas import BedCreate, BedOut, RoomCreate, RoomOut

router = APIRouter()


@router.post(
    "/apartments/{apartment_id}/rooms",
    response_model=RoomOut,
    status_code=status.HTTP_201_CREATED,
)
async def create_room(
    apartment_id: int,
    payload: RoomCreate,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> Room:
    apt = await db.get(Apartment, apartment_id)
    if not apt or apt.owner_id != user.id:
        raise HTTPException(status_code=404, detail="Apartment not found")

    room = Room(
        apartment_id=apt.id,
        name=payload.name,
        order_index=payload.order_index or 0,
    )
    db.add(room)
    await db.commit()
    await db.refresh(room)
    return room


@router.post(
    "/rooms/{room_id}/beds", response_model=BedOut, status_code=status.HTTP_201_CREATED
)
async def create_bed(
    room_id: int,
    payload: BedCreate,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> Bed:
    result = await db.execute(
        select(Room, Apartment)
        .join(Apartment, Room.apartment_id == Apartment.id)
        .where(Room.id == room_id)
    )
    row = result.first()
    if not row:
        raise HTTPException(status_code=404, detail="Room not found")
    room, apt = row
    if apt.owner_id != user.id:
        raise HTTPException(status_code=404, detail="Room not found")

    bed = Bed(
        room_id=room.id,
        label=payload.label,
        price_monthly=payload.price_monthly,
    )
    db.add(bed)
    await db.commit()
    await db.refresh(bed)
    return bed


@router.delete(
    "/rooms/{room_id}", status_code=status.HTTP_204_NO_CONTENT, response_model=None
)
async def delete_room(
    room_id: int,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> None:
    result = await db.execute(
        select(Room, Apartment)
        .join(Apartment, Room.apartment_id == Apartment.id)
        .where(Room.id == room_id)
    )
    row = result.first()
    if not row:
        raise HTTPException(status_code=404, detail="Room not found")
    room, apt = row
    if apt.owner_id != user.id:
        raise HTTPException(status_code=404, detail="Room not found")

    await db.delete(room)
    await db.commit()


@router.delete(
    "/beds/{bed_id}", status_code=status.HTTP_204_NO_CONTENT, response_model=None
)
async def delete_bed(
    bed_id: int,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> None:
    result = await db.execute(
        select(Bed, Room, Apartment)
        .join(Room, Bed.room_id == Room.id)
        .join(Apartment, Room.apartment_id == Apartment.id)
        .where(Bed.id == bed_id)
    )
    row = result.first()
    if not row:
        raise HTTPException(status_code=404, detail="Bed not found")
    bed, _room, apt = row
    if apt.owner_id != user.id:
        raise HTTPException(status_code=404, detail="Bed not found")

    await db.delete(bed)
    await db.commit()

