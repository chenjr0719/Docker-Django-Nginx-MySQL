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
COPY my.cnf /etc/mysql/

# uWSGI config
COPY uwsgi.ini /home/django/
COPY uwsgi_params /home/django/

# Model_example content
COPY admin.py /home/django/
COPY models.py /home/django/

# Copy initialization scripts
COPY start.sh /home/django/

EXPOSE 80
CMD ["/bin/bash", "/home/django/start.sh"]
