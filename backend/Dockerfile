FROM python:3.9.5-alpine3.13
WORKDIR /app
RUN \
    apk add --no-cache postgresql-libs && \
    apk add --no-cache --virtual .build-deps gcc musl-dev postgresql-dev g++
COPY ./requirements.txt /app/requirements.txt
RUN \
    python -m venv /venv && source /venv/bin/activate && pip install wheel &&\
    pip install --no-cache-dir -r requirements.txt && \
    apk --purge del .build-deps
ENV PATH /venv/bin:$PATH
CMD ["gunicorn", "-w", "6", "-b", "0.0.0.0", "app:app"]
COPY ./ /app/
