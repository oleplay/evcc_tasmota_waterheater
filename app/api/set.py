
from fastapi import APIRouter, Response, Query, Request
from utils import setdata
from api.read import read_all
import json

router = APIRouter(
    # name="Set Data",
)

@router.post("/set")
@router.get("/set")
def set_data(
    response: Response,
    request: Request,
    # set_data: str = "",
    # data: str = {}
):
    query_params = request.query_params._dict
    # print(query_params)
    # query_params=  str(query_params)
    r = setdata(query_params)
    test = read_all(Response)
    response.status_code = r.status_code
    return test
