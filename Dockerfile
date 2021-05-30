FROM python:3.9.5-alpine3.13
WORKDIR /app
COPY ./requirements.txt /app/requirements.txt
RUN \
    apk add --no-cache libpq && \
    apk add --no-cache --virtual .build-deps g++ gcc libpq postgresql-dev && \
    python -m venv /venv && source /venv/bin/activate && pip install wheel &&\
    pip install --no-cache-dir -r requirements.txt && \
    apk --purge del .build-deps
ENV PATH /venv/bin:$PATH
CMD gunicorn -b 0.0.0.0:${PORT} app:app
COPY ./ /app/
