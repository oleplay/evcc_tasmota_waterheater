# First Example from: https://fastapi.tiangolo.com/deployment/docker/

FROM python:3.10-slim

RUN addgroup --gid 1337 app && adduser --uid 1337 --gid 1337 --disabled-password --gecos "App User" app

COPY ./app /app

RUN pip install -r /app/requirements.txt

RUN chown app:app /app

USER 1337:1337

EXPOSE 80

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8080"]

# End of Dockerfile
