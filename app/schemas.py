from datetime import datetime
from typing import Literal

from pydantic import BaseModel, ConfigDict, EmailStr, Field

# ── Auth / User ────────────────────────────────────────────────────────────────


class UserCreate(BaseModel):
    name: str = Field(min_length=1, max_length=200)
    email: EmailStr
    password: str = Field(min_length=6, max_length=128)


class UserUpdate(BaseModel):
    name: str | None = Field(None, min_length=1, max_length=200)
    commission_rate: float | None = Field(None, ge=0.0, le=1.0)


class UserOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    name: str
    email: EmailStr | None = None
    commission_rate: float


# ── Apartments ─────────────────────────────────────────────────────────────────


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


# ── Rooms ──────────────────────────────────────────────────────────────────────


class RoomBase(BaseModel):
    name: str
    order_index: int | None = None


class RoomCreate(RoomBase):
    pass


class RoomUpdate(BaseModel):
    name: str | None = None
    order_index: int | None = None


# ── Beds ───────────────────────────────────────────────────────────────────────


class BedBase(BaseModel):
    label: str
    price_monthly: int


class BedCreate(BedBase):
    pass


class BedUpdate(BaseModel):
    label: str | None = None
    price_monthly: int | None = Field(None, ge=0)


# ── Tenants ────────────────────────────────────────────────────────────────────


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
    has_unpaid: bool = False


class TenantWithContextOut(TenantOut):
    """TenantOut enriched with apartment / room / bed location info."""

    bed_id: int | None
    bed_label: str | None
    room_name: str | None
    apt_id: int | None
    apt_name: str | None
    rent_amount: float | None = None


class TenantUpdate(BaseModel):
    name: str | None = None
    phone: str | None = None
    start_date: datetime | None = None


# ── Payments ───────────────────────────────────────────────────────────────────


class AssignTenantIn(BaseModel):
    bed_id: int
    name: str
    phone: str
    start_date: datetime
    rent_amount: float = Field(ge=0)
    month: str  # 'YYYY-MM'
    mark_paid: bool = True


class MarkPaidIn(BaseModel):
    month: str  # 'YYYY-MM'
    amount: float | None = Field(None, ge=0)


class RentPaymentOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    month: str
    amount: float
    status: Literal["paid", "unpaid"]


# ── Stats ──────────────────────────────────────────────────────────────────────


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


class EarningsOut(BaseModel):
    total_revenue: float
    commission_rate: float
    commission_amount: float
    apartments: list[ApartmentStatsOut]


# ── OTP ──────────────────────────────────────────────────────────────────────


class OTPRequestIn(BaseModel):
    phone: str


class OTPVerifyIn(BaseModel):
    phone: str
    code: str
    name: str | None = None


class OTPTokenOut(BaseModel):
    access_token: str
    token_type: str = "bearer"
    is_new_user: bool


# Required for forward-ref resolution (TenantOut inside BedOut)


class BedOut(BedBase):
    model_config = ConfigDict(from_attributes=True)

    id: int
    tenant: TenantOut | None = None


class RoomOut(RoomBase):
    model_config = ConfigDict(from_attributes=True)

    id: int
    beds: list[BedOut] = []


class ApartmentOut(ApartmentBase):
    model_config = ConfigDict(from_attributes=True)

    id: int
    rooms: list[RoomOut] = []


BedOut.model_rebuild()
