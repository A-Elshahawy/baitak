import random
from datetime import UTC, datetime, timedelta

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from ..config import get_settings
from ..db import get_db
from ..models import OTPCode, User
from ..schemas import OTPRequestIn, OTPVerifyIn, OTPTokenOut
from ..security import create_access_token
from ..services.whatsapp import send_otp_whatsapp

router = APIRouter()


def _normalize_phone(phone: str) -> str:
    digits = "".join(c for c in phone if c.isdigit())
    if digits.startswith("20") and len(digits) >= 12:
        return digits
    if digits.startswith("0") and len(digits) >= 10:
        return f"20{digits[1:]}"
    return f"20{digits}"


@router.post("/otp/request", status_code=status.HTTP_200_OK)
async def request_otp(
    payload: OTPRequestIn,
    db: AsyncSession = Depends(get_db),
) -> dict[str, str]:
    phone = _normalize_phone(payload.phone)

    code = f"{random.randint(100000, 999999)}"
    expires_at = datetime.now(UTC) + timedelta(minutes=get_settings().otp_ttl_minutes)

    otp = OTPCode(phone=phone, code=code, expires_at=expires_at, used=False)
    db.add(otp)
    await db.commit()

    await send_otp_whatsapp(phone, code)

    return {"message": "OTP sent"}


@router.post("/otp/verify", response_model=OTPTokenOut)
async def verify_otp(
    payload: OTPVerifyIn,
    db: AsyncSession = Depends(get_db),
) -> OTPTokenOut:
    phone = _normalize_phone(payload.phone)

    result = await db.execute(
        select(OTPCode)
        .where(OTPCode.phone == phone, OTPCode.used == False, OTPCode.expires_at > datetime.now(UTC))
        .order_by(OTPCode.id.desc())
    )
    otp_record = result.scalars().first()

    if not otp_record or otp_record.code != payload.code:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid or expired OTP")

    otp_record.used = True
    await db.commit()

    user_result = await db.execute(select(User).where(User.phone == phone))
    user = user_result.scalar_one_or_none()

    if user:
        token = create_access_token(str(user.id))
        return OTPTokenOut(access_token=token, is_new_user=False)

    name = payload.name or phone
    user = User(name=name, phone=phone, hashed_password=None, email=None)
    db.add(user)
    await db.commit()
    await db.refresh(user)

    token = create_access_token(str(user.id))
    return OTPTokenOut(access_token=token, is_new_user=True)
