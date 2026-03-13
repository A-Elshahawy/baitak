from datetime import datetime
from typing import Literal, Optional

from pydantic import BaseModel, ConfigDict, EmailStr, Field


class UserCreate(BaseModel):
    name: str = Field(min_length=1, max_length=200)
    email: EmailStr
    password: str = Field(min_length=6, max_length=128)


class UserOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    name: str
    email: EmailStr


class ApartmentBase(BaseModel):
    name: str
    area: str
    address: str
    floor: int = 1


class ApartmentCreate(ApartmentBase):
    pass


class ApartmentUpdate(BaseModel):
    name: str | None = None
    area: str | None = None
    address: str | None = None
    floor: int | None = None


class BedBase(BaseModel):
    label: str
    price_monthly: int


class RoomBase(BaseModel):
    name: str
    order_index: int | None = None


class RoomCreate(RoomBase):
    pass


class BedCreate(BedBase):
    pass


class BedOut(BedBase):
    model_config = ConfigDict(from_attributes=True)

    id: int
    tenant: Optional["TenantOut"] = None


class RoomOut(RoomBase):
    model_config = ConfigDict(from_attributes=True)

    id: int
    beds: list[BedOut] = []


class ApartmentOut(ApartmentBase):
    model_config = ConfigDict(from_attributes=True)

    id: int
    rooms: list[RoomOut] = []


class TenantBase(BaseModel):
    name: str
    phone: str
    start_date: datetime


class TenantCreate(TenantBase):
    bed_id: int


class TenantOut(TenantBase):
    model_config = ConfigDict(from_attributes=True)

    id: int
    active: bool


class RentPaymentOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    month: str
    amount: float
    status: Literal["paid", "unpaid"]


class TenantUpdate(BaseModel):
    name: str | None = None
    phone: str | None = None
    start_date: datetime | None = None


class AssignTenantIn(BaseModel):
    bed_id: int
    name: str
    phone: str
    start_date: datetime
    rent_amount: float
    month: str  # 'YYYY-MM'
    mark_paid: bool = True


class MarkPaidIn(BaseModel):
    month: str  # 'YYYY-MM'
    amount: float | None = None


class OverviewOut(BaseModel):
    apartments: int
    beds_total: int
    beds_occupied: int
    beds_vacant: int
    revenue_monthly: float
    unpaid_count: int


class ApartmentStatsOut(BaseModel):
    id: int
    name: str
    beds_total: int
    beds_occupied: int
    revenue_monthly: float


BedOut.model_rebuild()
