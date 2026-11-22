FROM python:3.12-slim

COPY app/requirements.txt /requirements.txt

RUN pip install -r /requirements.txt

COPY app/app.py /app.py

CMD ["python", "/app.py"]
