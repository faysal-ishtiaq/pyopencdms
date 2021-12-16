from typing import Optional
from pydantic import BaseModel


class Station(BaseModel):
    id: Optional[int]
    station_no: Optional[str]
    status_id: Optional[int]
    time_zone: Optional[str]
    region: Optional[str]
    latitude: Optional[float]
    longitude: Optional[float]
    start_date: Optional[str]
    end_date: Optional[str]
    region: Optional[str]
    ht_elev: Optional[float]

    class Config:
        allow_population_by_field_name = True
        orm_mode = True
        fields = {
            "id": "station_id",
            "time_zone": "timezone",
            "ht_elev": "elevation",
            "start_date": "start_datetime",
            "end_date": "end_datetime"
        }


class CreateStation(BaseModel):
    id: str
    station_no: str
    status_id: int
    time_zone: str
    region: str

    class Config:
        fields = {
            "id": "station_id",
            "time_zone": "timezone",
            "ht_elev": "elevation",
            "start_date": "start_datetime",
            "end_date": "end_datetime"
        }


class UpdateStation(BaseModel):
    station_no: Optional[str]
    status_id: Optional[int]
    time_zone: Optional[str]
    region: Optional[str]

    class Config:
        fields = {
            "id": "station_id",
            "time_zone": "timezone",
            "ht_elev": "elevation",
            "start_date": "start_datetime",
            "end_date": "end_datetime"
        }


class UniqueId(BaseModel):
    id: int







