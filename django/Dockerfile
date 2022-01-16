FROM python:3.9

ADD requirements.txt /app/requirements.txt
RUN set -ex \
    && python -m venv /env \
    && /env/bin/pip install --upgrade pip \
    && /env/bin/pip install --no-cache-dir -r /app/requirements.txt 

ADD asset-registry /app
WORKDIR /app

ENV PATH /env/bin:$PATH

EXPOSE 8000

CMD ["gunicorn", "--bind", ":8000", "--workers", "3", "mysite.wsgi"]
ENTRYPOINT [ "sh", "-c", "python manage.py makemigrations && python manage.py migrate && python manage.py initadmin && python manage.py runserver 0.0.0.0:8000" ]