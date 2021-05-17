FROM python:3.9.5-alpine3.13
COPY ./ /app/
WORKDIR /app
RUN python -m venv /venv && source /venv/bin/activate && pip install -r requirements.txt
ENV PATH /venv/bin:$PATH
CMD ["gunicorn", "-w", "6", "-b", "0.0.0.0", "app:app"]
