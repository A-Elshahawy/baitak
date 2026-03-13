from fastapi import APIRouter

from . import apartments, auth, rooms, stats, tenants  # noqa: F401

api_router = APIRouter()

api_router.include_router(auth.router, prefix="/auth", tags=["auth"])
api_router.include_router(apartments.router, prefix="/apartments", tags=["apartments"])
api_router.include_router(rooms.router, tags=["rooms"])
api_router.include_router(tenants.router, prefix="/tenants", tags=["tenants"])
api_router.include_router(stats.router, prefix="/stats", tags=["stats"])

