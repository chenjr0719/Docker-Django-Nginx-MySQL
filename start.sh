#!/bin/bash

SETTING_PATH=`find /home/django/ -name settings.py`

# Check is there already exist any django project
if [ -z "$SETTING_PATH" ] ; then

    # Create new django project
    mkdir -p /home/django/website/
    django-admin startproject website /home/django/website

    SETTING_PATH=`find /home/django/ -name settings.py`

else

    # Install requirements
    if [ -f /home/django/website/requirements.txt ]; then
        pip3 install -r /home/django/website/requirements.txt
    fi

    # Backup data from SQLite
    if [ -f /home/django/website/db.sqlite3 ] ; then
        python3 /home/django/website/manage.py dumpdata -e sessions -e admin -e contenttypes -e auth --natural-primary --natural-foreign --indent=4 > /home/django/dump.json
    fi

fi

if [ ! -f /home/django/password.txt ] ; then

    # Start mysql
    /usr/bin/mysqld_safe & sleep 5s

    # Set password
    MYSQL_ROOT_PASSWORD=`pwgen -c -n -1 12`
    MYSQL_DJANGO_PASSWORD=`pwgen -c -n -1 12`
    DJANGO_ADMIN_PASSWORD=`pwgen -c -n -1 12`

    # Output password
    echo -e "MYSQL_ROOT_PASSWORD = $MYSQL_ROOT_PASSWORD\nMYSQL_DJANGO_PASSWORD = $MYSQL_DJANGO_PASSWORD\nDJANGO_ADMIN_PASSWORD = $DJANGO_ADMIN_PASSWORD" > /home/django/password.txt

    # Initialize MySQL
    mysqladmin -u root password $MYSQL_ROOT_PASSWORD
    mysql -uroot -p$MYSQL_ROOT_PASSWORD -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD' WITH GRANT OPTION; FLUSH PRIVILEGES;"
    mysql -uroot -p$MYSQL_ROOT_PASSWORD -e "CREATE DATABASE django DEFAULT CHARACTER SET utf8; GRANT ALL PRIVILEGES ON django.* TO 'django'@'localhost' IDENTIFIED BY '$MYSQL_DJANGO_PASSWORD'; FLUSH PRIVILEGES;"

    # Install MySQL adapter for Python
    pip3 install mysqlclient

    # Create model_example app
    mkdir -p /home/django/website/model_example/
    django-admin startapp model_example /home/django/website/model_example/
    mv /home/django/admin.py /home/django/website/model_example/
    mv /home/django/models.py /home/django/website/model_example/

    # Add model_example app
    sed -i "s|'django.contrib.staticfiles'|'django.contrib.staticfiles',\n    'model_example'|g" $SETTING_PATH

    # Modify database setting to MySQL
    sed -i "s|django.db.backends.sqlite3|django.db.backends.mysql|g" $SETTING_PATH
    sed -i "s|os.path.join(BASE_DIR, 'db.sqlite3')|'django',\n        'USER': 'django',\n        'PASSWORD': '$MYSQL_DJANGO_PASSWORD'|g" $SETTING_PATH

    # Modify static files setting
    sed -i "s|STATIC_URL = '/static/'|STATIC_URL = '/static/'\n\nSTATIC_ROOT = os.path.join(BASE_DIR, 'static')|g" $SETTING_PATH

    # Django setting
    python3 /home/django/website/manage.py makemigrations
    python3 /home/django/website/manage.py migrate
    echo yes | python3 /home/django/website/manage.py collectstatic
    echo "from django.contrib.auth.models import User; User.objects.create_superuser('admin', 'admin@example.com', '$DJANGO_ADMIN_PASSWORD')" | python3 /home/django/website/manage.py shell

    # Data migration
    DUMP_PATH=`find /home/django/ -name dump.json`

    if [ ! -z "$DUMP_PATH" ] ; then
        python3 /home/django/website/manage.py loaddata $DUMP_PATH
    fi

    killall mysqld
    
fi

# Start all the services
/usr/bin/supervisord -n
