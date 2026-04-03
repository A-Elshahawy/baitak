from __future__ import annotations

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from ..db import get_db
from ..deps import get_current_user
from ..models import Apartment, Bed, Room, User
from ..schemas import BedCreate, BedOut, BedUpdate, RoomCreate, RoomOut, RoomUpdate

router = APIRouter()


async def _room_with_owner_check(room_id: int, user: User, db: AsyncSession) -> Room:
    room = await db.get(Room, room_id)
    if not room:
        raise HTTPException(status_code=404, detail="Room not found")
    apt = await db.get(Apartment, room.apartment_id)
    if not apt or apt.owner_id != user.id:
        raise HTTPException(status_code=404, detail="Room not found")
    return room


async def _bed_with_owner_check(bed_id: int, user: User, db: AsyncSession) -> Bed:
    bed = await db.get(Bed, bed_id)
    if not bed:
        raise HTTPException(status_code=404, detail="Bed not found")
    room = await db.get(Room, bed.room_id)
    if not room:
        raise HTTPException(status_code=404, detail="Bed not found")
    apt = await db.get(Apartment, room.apartment_id)
    if not apt or apt.owner_id != user.id:
        raise HTTPException(status_code=404, detail="Bed not found")
    return bed


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
    result = await db.execute(
        select(Room).options(selectinload(Room.beds).selectinload(Bed.tenant)).where(Room.id == room.id)
    )
    return result.scalar_one()


@router.patch("/rooms/{room_id}", response_model=RoomOut)
async def update_room(
    room_id: int,
    payload: RoomUpdate,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> Room:
    room = await _room_with_owner_check(room_id, user, db)
    for field, value in payload.model_dump(exclude_unset=True).items():
        setattr(room, field, value)
    await db.commit()
    result = await db.execute(
        select(Room).options(selectinload(Room.beds).selectinload(Bed.tenant)).where(Room.id == room.id)
    )
    return result.scalar_one()


@router.delete("/rooms/{room_id}", status_code=status.HTTP_204_NO_CONTENT, response_model=None)
async def delete_room(
    room_id: int,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> None:
    room = await _room_with_owner_check(room_id, user, db)
    await db.delete(room)
    await db.commit()


@router.post("/rooms/{room_id}/beds", response_model=BedOut, status_code=status.HTTP_201_CREATED)
async def create_bed(
    room_id: int,
    payload: BedCreate,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> Bed:
    room = await _room_with_owner_check(room_id, user, db)
    bed = Bed(room_id=room.id, label=payload.label, price_monthly=payload.price_monthly)
    db.add(bed)
    await db.commit()
    result = await db.execute(
        select(Bed).options(selectinload(Bed.tenant)).where(Bed.id == bed.id)
    )
    return result.scalar_one()


@router.patch("/beds/{bed_id}", response_model=BedOut)
async def update_bed(
    bed_id: int,
    payload: BedUpdate,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> Bed:
    bed = await _bed_with_owner_check(bed_id, user, db)
    for field, value in payload.model_dump(exclude_unset=True).items():
        setattr(bed, field, value)
    await db.commit()
    result = await db.execute(
        select(Bed).options(selectinload(Bed.tenant)).where(Bed.id == bed.id)
    )
    return result.scalar_one()


@router.delete("/beds/{bed_id}", status_code=status.HTTP_204_NO_CONTENT, response_model=None)
async def delete_bed(
    bed_id: int,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> None:
    bed = await _bed_with_owner_check(bed_id, user, db)
    await db.delete(bed)
    await db.commit()
