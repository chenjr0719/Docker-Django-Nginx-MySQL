# Docker-Django-Nginx-MySQL

Dockerfile for Django with uWSGI, Nginx, MySQL, Python 3.

## About this Image/Dockerfile

This **Image/Dockerfile** aims to create a container for **Django** with **MySQL**, **Python 3** and using **uWSGI**, **Nginx** to hosting.

## How to use?

You can build this **Dockerfile** yourself:

```
sudo docker build -t "chenjr0719/django-nginx-mysql" .
```

Or, just pull my image:

```
sudo docker pull chenjr0719/django-nginx-mysql
```

Then, run this image:

```
sudo docker run -itd -p 80:80 chenjr0719/django-nginx-mysql
```

Now, you can see the initial project of **Django** at http://127.0.0.1

You can also change it to a different **port**.

For example, use 8080:

```
sudo docker run -itd -p 8080:80 chenjr0719/django-nginx-mysql
```

## Use your Django project?

If you want to use your **Django** project which you already developed, use following command:

```
sudo docker run -itd -p 80:80 -v $YOUR_PROJECET_DIR:/home/django/website chenjr0719/django-nginx-mysql
```

### Modify Django setting with MySQL

You have to make sure that your **settings.py** is already set all setting with **MySQL**.

1. Enter to your container:

   ```
   sudo docker exec -it $CONTAINER_ID bash
   ```

2. Query password of **MySQL**:

   ```
   cat /home/django/password.txt
   ```

3. Modify **settings.py**:

   ```
   SETTING_PATH=`find /home/django/website -name settings.py`
   sed -i "s|'django.contrib.staticfiles'|'django.contrib.staticfiles',\n    '$YOUR_APP_NAME'|g" $SETTING_PATH
   sed -i "s|django.db.backends.sqlite3|django.db.backends.mysql|g" $SETTING_PATH
   sed -i "s|os.path.join(BASE_DIR, 'db.sqlite3')|'django',\n        'USER': 'django',\n        'PASSWORD': '$MYSQL_DJANGO_PASSWORD'|g" $SETTING_PATH
   ```

4. Let **django** create tables automatically:

   ```
   python3 /home/django/website/manage.py makemigrations
   python3 /home/django/website/manage.py migrate
   ```

5. Exit your container and restart it:

   ```
   exit
   sudo docker restart $CONTAINER_ID
   ```

### Modify project name

If your project name is not **websit**, this image will not work properly.

you need modify the setting of **uwsgi.ini** in your container:

```
sudo docker exec $CONTAINER_ID sed -i "s|module=website.wsgi:application|module=$PROJECT_NAME.wsgi:application|g" /home/django/uwsgi.ini
sudo docker restart $CONTAINER_ID
```

## About Django static files

If you want to use **Django** static files, you have to:

1. Enter to your container:

   ```
   sudo docker exec -it $CONTAINER_ID bash
   ```

2. Modify the setting of **Django**.

   ```
   SETTING_PATH=`find /home/django/website -name settings.py`
   vim $SETTING_PATH
   ```

   In the **Static files** section, if your static files are in templates/static, add following setting:

   ```
   STATICFILES_DIRS = [
       os.path.join(BASE_DIR, "templates/static"),
   ]

   STATIC_ROOT = os.path.join(BASE_DIR, "static")
   ```

3. Run following command to collect all static files of your project into a folder.

   In default it will use /static/, you can change it by modify STATIC_ROOT in **settings.py**

   ```
   echo yes | python3 /home/django/website/manage.py collectstatic
   ```

4. If you want to use different name of static folder, you need to modify the setting of **nginx-site.conf** in your container.

   You can this command:

   ```
   sed -i "s|/home/django/website/static|/home/django/website/$STATIC_FOLDER_NAME|g" /etc/nginx/sites-available/default
   ```

5. Exit your container and restart it:

   ```
   exit
   sudo docker restart $CONTAINER_ID
   ```
