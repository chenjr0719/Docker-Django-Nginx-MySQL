# Docker-Django-Nginx-MySQL

Dockerfile for Django with uWSGI, Nginx, MySQL, Python 3.

This **Image/Dockerfile** aims to create a container for **Django** with **MySQL**, **Python 3** and using **uWSGI**, **Nginx** to hosting.


## How to use?

You can build this **Dockerfile** yourself:

```
sudo docker build -t "chenjr0719/django-nginx-mysql" .
```

Or, just pull my **image**:

```
sudo docker pull chenjr0719/django-nginx-mysql
```

Then, run this image:

```
sudo docker run -itd -p 80:80 chenjr0719/django-nginx-mysql
```

Wait a minute, you can see the initial project of **Django** at http://127.0.0.1

### Check it work properly

You can check is **Django** work properly with **MySQL Server** by:

1. First, query your **Django Admin Password**:

   ```
   sudo docker exec -it $CONTAINER_ID cat /home/django/password.txt
   ```

2. Access http://127.0.0.1/admin and log in as Username: admin.

3. Choose **Model_Example** to test **CRUD** function.


## Use your Django project?

If you want to use your **Django** project which you already developed, use following command:

```
sudo docker run -itd -p 80:80 -v $PROJECET_DIR:/home/django/website chenjr0719/django-nginx-mysql
```

### Project requirements

Make sure you already add your **requirements** module at $PROJECET_DIR/requirements.txt.

This image will auto install all requirements module in this file.

### Data migration

If you are using **SQLite**, this image will auto migrate your data into **MySQL Server**.

But, if you are using other database, you need to **dump** data yourself.

Using this command:

```
python manage.py dumpdata -e sessions -e admin -e contenttypes -e auth --natural-primary --natural-foreign --indent=4 > $PROJECT_DIR/dump.json
```

### Modify project name

If your project name is not **website**, this image will not work properly.

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

3. Run the following command to collect all static files of your project into a folder.

  In default it will use /static/, you can change it by modifying STATIC_ROOT in **settings.py**

  ```
  echo yes | python3 /home/django/website/manage.py collectstatic
  ```

4. If you want to use different name of static folder, you need to modify the setting of **nginx-site.conf** in your container.

  You can use this command:

  ```
  sed -i "s|/home/django/website/static|/home/django/website/$STATIC_FOLDER_NAME|g" /etc/nginx/sites-available/default
  ```

5. Exit your container and restart it:

  ```
  exit
  sudo docker restart $CONTAINER_ID
  ```
