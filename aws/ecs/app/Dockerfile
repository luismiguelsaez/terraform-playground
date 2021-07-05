FROM python:3.9-alpine

LABEL Description="REST API that returns geolocation of the running container"
LABEL Author="Luis Miguel Sáez Martín"

RUN adduser -h /app -D -H -u 1000 application

COPY requirements.txt /requirements.txt
RUN pip install -r requirements.txt

RUN mkdir /app
ADD code /app
RUN chown -R application. /app

WORKDIR /app
USER application

ENTRYPOINT ["flask","run","--host","0.0.0.0","--port","5000"]
