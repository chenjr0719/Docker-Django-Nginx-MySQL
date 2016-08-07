From ubuntu:16.04

MAINTAINER Jacob chenjr0719@gmail.com

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y \
    git \
    vim \
    python3 \
    python3-pip \
    nginx \
    supervisor \
    mysql-server \
    mysql-client \
    libmysqld-dev \
    pwgen && rm -rf /var/lib/apt/lists/*

RUN pip3 install uwsgi django

# nginx config
RUN echo "daemon off;" >> /etc/nginx/nginx.conf
COPY nginx-site.conf /etc/nginx/sites-available/default

# supervisor config
COPY supervisor.conf /etc/supervisor/conf.d/

# mysql config
RUN sed -i -e"s/^bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" /etc/mysql/my.cnf

# uWSGI config
COPY uwsgi.ini /home/django/
COPY uwsgi_params /home/django/

# Create django project
RUN mkdir -p /home/django/website/
RUN django-admin startproject website /home/django/website

# Create model_example app
RUN mkdir -p /home/django/website/model_example/
RUN django-admin startapp model_example /home/django/website/model_example/
COPY models.py /home/django/website/model_example/
COPY admin.py /home/django/website/model_example/

COPY start_model_example.sh /home/django/

EXPOSE 80
CMD ["/bin/bash", "/home/django/start_model_example.sh"]
