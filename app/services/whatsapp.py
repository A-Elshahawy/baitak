import httpx
from ..config import get_settings


async def send_otp_whatsapp(phone_e164: str, code: str) -> None:
    """
    phone_e164: "201012345678" (no +)
    Sends: "كود بيتك هو: 123456"
    """
    settings = get_settings()
    if not settings.whatsapp_token:
        print(f"[DEV OTP] {phone_e164} → {code}")
        return

    url = f"https://graph.facebook.com/v19.0/{settings.whatsapp_phone_id}/messages"
    headers = {"Authorization": f"Bearer {settings.whatsapp_token}"}
    payload = {
        "messaging_product": "whatsapp",
        "to": phone_e164,
        "type": "text",
        "text": {"body": f"كود بيتك هو: {code} (صالح ٥ دقائق)"},
    }
    async with httpx.AsyncClient() as client:
        r = await client.post(url, json=payload, headers=headers)
        r.raise_for_status()
