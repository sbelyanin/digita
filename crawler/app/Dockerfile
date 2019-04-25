FROM python:3.6.0-alpine as base
FROM BASE as builder

RUN apk --no-cache add gcc musl-dev

WORKDIR /install
COPY requirements.txt /requirements.txt
RUN pip install --upgrade pip && pip install --install-option="--prefix=/install" -r /requirements.txt


FROM base

COPY --from=builder /install /usr/local

WORKDIR /app
ADD . /app

ENV MONGO mongodb
#адрес `mongodb`-хоста
ENV MONGO_PORT 27017
#порт для подключения к `mongodb`-хосту
ENV RMQ_HOST rabbitmq
#адрес `rabbitmq`-хоста
ENV RMQ_PORT 5672
#номер порта для подключения
ENV RMQ_VHOST /
#виртуальный хост в rabbitmq
ENV RMQ_QUEUE urls
#имя очереди `rabbitmq`
ENV RMQ_USERNAME guest
#пользователь для подключения к `rabbitmq`-серверу
ENV RMQ_PASSWORD guest
#пароль пользователя
ENV CHECK_INTERVAL 60
#минимальное время между повторными проверками одного и того же `url`
ENV EXCLUDE_URLS '.*github.com'
#адреса которые будут исключены из обхода записанные через запятую в формате простых регулярных выражений.

ENTRYPOINT ["python3", "-u", "crawler/crawler.py"]

CMD ["https://vitkhab.github.io/search_engine_test_site/"] 
