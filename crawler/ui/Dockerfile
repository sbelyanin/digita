FROM python:3.6.0-alpine as base
FROM BASE as builder

RUN apk --no-cache add gcc musl-dev

WORKDIR /install
COPY requirements.txt /requirements.txt
RUN pip install --upgrade pip && pip install --install-option="--prefix=/install" -r /requirements.txt


FROM base

COPY --from=builder /install /usr/local

ADD . /app
WORKDIR /app/ui

ENV MONGO mongodb
ENV MONGO_PORT 27017
ENV FLASK_APP ui.py


ENTRYPOINT ["gunicorn"]

CMD ["ui:app", "-b", "0.0.0.0"] 

