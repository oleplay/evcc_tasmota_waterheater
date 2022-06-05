from typing import Optional
from fastapi import APIRouter, Response, Query
from utils import getdata
import json

# fastapi prefix /api
router = APIRouter(
)

# Hello world

@router.get("/status")
@router.get("/", )
# add filter alf
def read_all(
    response: Response,

    filter: Optional[str]   = None
):
    
    r = getdata()
    response.status_code = r.status_code
    text = str.replace(r.text, "\'", '"')
    # r.text().replace("'", '"')
    text = json.loads(text)
    text.pop('StatusSNS', None)
    if filter:
        filtered_data = {}
        filter = str.split(filter, ',')
        for key in filter:
            filtered_data[key] = text[key]
        return filtered_data
    else:
        return text


