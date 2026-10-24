+++
title = "My Favorite Docker Setup for Django Development"
date = 2019-06-14T15:47:01-07:00
draft = false
tags = [
    "programming",
    "docker",
    "django",
    "developer experience"
]
categories = [
    "Blog",
    "Programming"
]
summary = "This is my current Docker set up for Django development. I think it works really well, so I wanted to share."
+++

**Note:** This article was written in 2019. I've updated what I can see as being
outdated or outdate-able, so it _should_ be pretty reliable, but I make no
promises. If you find something that's wrong, please [let me know](/social/).


At [my company](https://oreilly.com), we've been developing a common Docker
workflow for all of our microservices to use. I _really_ want us to get it
to a state where we can open source it but that seems to be a long way off.
I've slowly been adapting parts of it for local, personal development and
I think it's to a place where I can share it with all of you.

I'm not going to go into what Docker is, how to install it, or what all you
can do Docker. Instead, I'm just going to focus on the files you need to
create or edit and the commands you'll run. Alright, let's jump in!

# Django project

I like to keep a virtual environment around to hold packages for my editor
and for local commands (like the excellent [`pip-tools`]). Create yourself a
virtual environment, activate it, install Django, and start a new Django
project, more-or-less like so:

{{< code lang="bash" >}}
$ mkdir my_project && cd my_project
$ python3 -m venv venv
$ source venv/bin/activate
$ pip install Django
$ django-admin startproject app
{{< /code >}}

I'll often just call my project `project` or `app` but feel free to use a
more descriptive name. Also, at this point, do any project configurations
that you need to, like setting up a `git` repo.

# Docker

There are lots of different ways to build your `Dockerfile` and to configure
the resulting images. If you have some preferred method that I'm not using
here, feel free to use your method (and tell me about it!). I am _not_ a
Docker expert, so buyer beware!

{{< code file="Dockerfile" lang="dockerfile" >}}
FROM python:<USE WHAT'S CURRENT>

RUN apt-get update && \
  apt-get install -y && \
  pip3 install uwsgi

COPY ./app /opt/app

RUN python3 -m pip install --upgrade pip
RUN pip3 install -r /opt/app/requirements.txt

ENV DJANGO_ENV=prod
ENV PYTHONUNBUFFERED 1
ENV PYTHONPATH /opt/app/

EXPOSE 8000

CMD ["uwsgi", "--ini", "/opt/app/uwsgi.ini"]

{{< /code >}}

Starting from the top, this `Dockerfile` starts by using the `python:3.7` image,
which gives you a recent Debian version with Python installed. Next, it
automatically updates the package list and installs any necessary updates. Then
it installs [`uwsgi`] which is how we'll run our Django project.

The `COPY` line will copy your project, `app`, into `/opt/app` in your Docker
image. This path is completely customizable if you have a preferred location
for your projects to live. Keep this path in mind, though, as you'll need it
later on.

The two `RUN` lines should be fairly understandable if you've used Python for
awhile. The first upgrades the existing `pip` installation. The second installs
all of your project's requirements (if you haven't, now is a good time to
run `pip freeze > app/requirements.txt` so you'll have the necessary
`requirements.txt` file).

The three `ENV` lines set up some environment variables. The first says that
this is a production environment (you'd override this in a development-only
`docker-compose.override.yml` file). The second prevents Python from buffering
output. And the last one adds `/opt/app`, where we're putting our project, onto
the `PYTHONPATH`. I'm not certain this last one is needed (and I'll leave using
the first one up to you), but it seems to make a test discovery a little easier.

Next, we expose port 8000, Django's default port. This makes debugging easier
but we won't rely on port 8000 for development or deployment. And, lastly, we
run `uwsgi` with a `CMD` statement. That statement mentions a `uwsgi.ini` file.
What's in that?

{{< code file="app/uswgi.ini" lang="ini">}}
[uwsgi]
http-socket = :8000
chdir = /opt/app
module = app.wsgi
master = 1
processes = 2
threads = 2
py-autoreload = 3
{{< /code >}}

Much like with Docker, I am _not_ a `uwsgi` expert, but this seems to work
really well. Let me walk you through it as well.

`http-socket` is a nice little goody we get for using a modern `uwsgi`. This
basically tells `uwsgi` to bind itself to port 8000 for incoming HTTP requests
and to respond to them.

The `chdir` line changes the directory that `uwsgi` is
operating in and `module` tells it what module holds the `wsgi` process. If
you picked a different directory in your `Dockerfile` or a different project
name, you'll need to update both of these directives.

The next three lines, `master`, `processes`, and `threads`, control how `uwsgi`
spawns processes and threads. This setup works for my machines but you may
need to tweak some numbers depending on your machine. You can read a lot more
about them in the [`uwsgi` docs].

Finally, the `py-autoreload` directive tells `uwsgi` to restart when it detects
a change to a file. The `3` controls how many seconds should elapse between
checks. You can change this speed if your system is really fast or slow but
3 seems to be a good default.

Alright, at this point, you should be able to do `docker build .` to build your
image. One of the last lines will contain the image name that was just built.
In my run while writing this, it was `bbf8ba9d356d`. Then you can use
`docker run -p 8000:8000 bbf8ba9d356d` to start it and bind port 8000 on the
running image to port 8000 on your local machine. You should be able to visit
[http://localhost:8000] and see the "Welcome to Django" page. If you see an
error, that's alright, 'cause we're not done. Hit `ctrl-c` to end the process
(you may need to check `docker ps` to make sure it ended. If it didn't, you can
stop it with `docker stop <container id>`).

# docker-compose

Most Django projects need more than just a `wsgi` process. So let's add a few
extra bits like `nginx` and a database. We'll configure all of this with a new
file, `docker-compose.yml`. Because this file is pretty long, I'm going to
show and explain it section-by-section.

{{< code file="docker-compose.yml" lang="yaml" >}}
version: "3"

volumes:
  pg_data: {}
  pg_backups: {}

networks:
  frontend:
    driver: bridge
  backend:
    driver: bridge

services:
{{< /code >}}

This section isn't very exciting but it's necessary. First we define the version
of `docker-compose` that this file should conform to. We're using `"3"` which is
the newest version at the time of writing.

In the `volumes` section, we define two persistent volumes that Postgres, our
database, will use to store data and backups.

And, lastly, in the `networks` section, we create two networks. We'll use these
to keep communication between containers separate. You can ignore this part if
you want, I just like it for some extra organization. If you have many services,
like in a microservice architecture, you can use these networks to make service-
to-service communication easier, but that's beyond the scope of this article.

Our next section is `services` and it makes up the bulk of the file. Let me
show you each service that we'll be running. All of these snippets should be
indented inside the `services` block.

## `nginx` service

{{< code file="docker-compose.yml" lang="yaml" >}}
nginx:
  image: nginx:<USE WHAT'S CURRENT>
  ports:
    - "80:80"
    - "443:443"
  volumes:
    - ./data/nginx:/etc/nginx/conf.d
  command: '/bin/sh -c ''while :; do sleep 6h & wait $${!}; nginx -s reload; done & nginx -g "daemon off;"'''
  networks:
    - frontend
  depends_on:
    - app
{{< /code >}}

First is our `nginx` section, which will give us the excellent [`nginx` server].
We tell Docker to use the `nginx` image, version TBD, you'll need to find a
recent release. This will give us a small Linux distribution with `nginx`
already installed. Next we expose two ports, 80 and 443, so we can reach
`nginx` from our web browser. The 443 port is a bit of forward-thinking
for HTTPS connections. I'll leave the HTTPS certificate and configuration
to you, though.

Next, we mount a local directory, `./data/nginx`, into the configuration
directory for `nginx`. This lets us easily override configuration files.

Then we have a command that will reload `nginx` every 6 hours. We don't really
need this in this example but it's handy when you're running something like
[`certbot`] and want to be sure you have up-to-date certificates.

Our last two directives tell `nginx` to join the `frontend` network and that
it should start the `app` service if it's not already running.

Before I forget, let's look at that `nginx` configuration file. Mine is pretty
simple at this point.

{{< code file="data/nginx/app.conf" lang="nginx" >}}
upstream app {
    server app:8000;
}

server {
    listen 80;
    server_name localhost;

    location / {
        proxy_pass http://app;
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
{{< /code >}}

If you're comfortable with `nginx` configuration, you probably understand this
file, but I'll go over it for those of you, like me, who need an introduction
or refresher from time to time.

First, we define an upstream server named `app`. This server lives at the
network location of `app` and uses port 8000. Our Django service will be named
`app` and Django listens on port 8000, so this should be a good match.

The `location` block defines what happens when the server gets a request to `/`
or any deeper paths (`/foo` or `/foo/bar/baz.html`, for example). We tell `nginx`
to pass those requests to the `app` upstream and we set a few headers. These
headers will make sure Django knows what host made the request and provide the
IP address for the actual requester (instead of `nginx`).

## `database` service

Now we can set up our database. I like Postgres the best but if you love another
database, feel free to use it.

{{< code file="docker-compose.yml" lang="yaml" >}}
database:
  image: postgres:<USE WHAT'S CURRENT>
  ports:
    - "5432:5432"
  volumes:
    - pg_data:/var/lib/postgresql/data
    - pg_backups:/pg_backups
  env_file:
    - data/postgres/database_env
  networks:
    - backend
{{< /code >}}

This should look quite a bit like the `nginx` section from above. Again, we're
using an image so we don't have to build all of this ourselves. In this case,
it's `postgres:<CURRENT VERSION>` which will give us an install of Postgres. Next, we
expose port 5432. If you don't want to use a local database GUI, you can leave
this out (but I think you need to add `expose: 5432` so other services can
see your database).

Then we mount our two volumes that we defined earlier into the image. I'm not
including any information on how to create, store, and use your Postgres
backups, but you have a persistent volume, so figure that out :).

The last directive, `networks`, you've seen before. We're connecting our
`database` container to our `backend` network. Since `nginx` and `database` don't
share a network, they shouldn't be able to see each other.

But what about that `env_file` section? That allows you to specify environment
variables in a separate file. If you don't track this file in version control,
you can store sensitive secrets in it. There are better ways to store secrets,
though. Let me show you what's in my file:

{{< code file="data/postgres/database_env" lang="bash" >}}
POSTGRES_USER=database_role
POSTGRES_PASSWORD=database_password
POSTGRES_DB=project_database
{{< /code >}}

This sets up three environment variables. `POSTGRES_USER` allows you to add a
new role to Postgres. `POSTGRES_PASSWORD` sets the password for either the
default `postgres` user or the user you specified in `POSTGRES_USER`. Lastly,
`POSTGRES_DB` will create a new database, owned by `POSTGRES_USER`.

## `app` service

This service is where your Django project lives and runs. It's not that
different from the previous services but it'll use our `Dockerfile`-produced
image instead of a pre-built image.

{{< code file="docker-compose.yml" lang="yaml" >}}
app:
  build: .
  restart: always
  ports:
    - "8000:8000"
  depends_on:
    - database
  networks:
    - frontend
    - backend
  volumes:
    - ./app:/opt/app
{{< /code >}}

The first difference is the `build` directive. This tells Docker to build the
`Dockerfile` in the current directory and use the resulting image for this
service's containers. The `restart` directive says to restart this container
if it crashes for some reason. And `ports`, again, exposes port 8000 to us for
debugging purposes or just to connect to if you didn't want to start `nginx`.
`depends_on` and `networks` you've seen before, but this time we connect to
_both_ networks.

Finally, the `volumes` directive will mount your local `./app` directory into
the container at `/opt/app` (change this if you want your project mounted
elsewhere). This will allow you to edit files locally, just like you're
probably used to, but have the container notice the changes and restart the
`uwsgi` process. Notice that we are _not_ telling Docker how to run our Django
project. We're expecting it to be available because of the `uwsgi` command in
the `Dockerfile`.

Without this `volumes` mount, you would have to rebuild your container every
time you made a change to a file. As you can imagine, this gets old really fast.

## `manage` service

This service, and the next one, are the entire reason I wrote this article. I
know, I went and buried them at the bottom. These two, though, make a few things
much easier and nicer when you're using Docker.

{{< code file="docker-compose.yml" lang="yaml" >}}
manage:
  build: .
  command: shell
  entrypoint: /usr/local/bin/python3 /opt/app/manage.py
  networks:
    - backend
  volumes:
    - ./app:/opt/app
  depends_on:
    - database
{{< /code >}}

I'm not going to cover `build`, `networks`, `volumes`, or `depends_on` since
you've seen them before. Besides, most of the magic is in `command` and
`entrypoint`.

Let's start with `entrypoint`, even though it comes second. This directive tells
Docker where to start running commands. In this case, we want to use our
Python install to run our project's `manage.py`. Then, if no commands are given,
it'll run whatever is in the `command` directive. So, by default, this container
runs `/usr/local/bin/python3 /opt/app/manage.py shell`, which will put us into
a Django shell. If you had [`django-extensions`] installed, you could change
this to `shell_plus`, for example.

Jumping ahead just slightly, this service allows you to do commands like
`docker-compose run --rm manage makemigrations` to make any new migrations. This
means you'll use your Docker-based Python and Django installation to make your
migrations, which removes the need for that local virtual environment (although
I still keep one around).

## `tests` service

And, finally, our `tests` service. This service will let us run tests in a
container just like our `app` one. Again, this will make running test easier
and make sure that our tests run in an environment very similar to the project
itself. It's a win-win in my book!

{{< code file="docker-compose.yml" lang="yaml" >}}
tests:
  build: .
  command: /opt/app/
  entrypoint: /usr/local/bin/py.test -W error
  restart: "no"
  networks:
    - backend
  volumes:
    - ./app:/opt/app
  depends_on:
    - database
    - app
{{< /code >}}

Again, I'm going to skip `build`, `networks`, `volumes`, and `depends_on`. You've
seen `restart` before but this time it's set to `"no"`. This will let the
container stop and stay stopped until the next time we run it. We want this
behavior because there's no reason to keep the container running after the tests
finish their run.

For this service, `entrypoint` starts up [`pytest`], telling it to treat
warnings like an error (you can turn this off if you want) and `command` points
it to our project so it can discover tests throughout the project.

We do need to add a `pytest.ini` file, though, to configure `pytest` just a bit.
You'll also want to add `pytest` and `pytest-django` to your `requirements.txt`.

{{< code="app/pytest.ini" lang="ini">}}
[pytest]
norecursedirs = __pycache__
DJANGO_SETTINGS_MODULE = app.settings
python_file = tests.py test_*.py *_tests.py
{{< /code >}}

This configuration tells `pytest` not to look through any `__pycache__`
directories for tests. It also sets where Django's settings live for
`pytest-django` and which files to look for to find tests.

Much like the `manage` service, you can use `docker-compose run --rm tests` and
Docker will run all of your tests and give you the results. Feel free to add
other plugins like `pytest-cov` or `pytest-xdist` to make testing more complete.

# Running it all

Assuming everything is entered correctly and I'm not completely misguided, you
should now be able to run `docker-compose build` in the directory that houses
your `docker-compose.yml` file. This will download the `python`, `nginx`, and
`postgres` images, build your local image, and install your dependencies.

If you don't get any errors, run `docker-compose up` and you should see all
of your containers start up. Since your `tests` container is included by
default, Docker will run all of your tests for you. You can add on the `-D`
argument to put your containers in the background, but I usually leave that
off. Open up `http://localhost` and you should see the welcome page.

Now you need to migrate and create a superuser.
`docker-compose run --rm manage migrate` will run all of your existing
migrations from Django itself. And
`docker-compose run --rm manage createsuperuser` will give you the necessary
prompts to create a new superuser.

Time to start building your next great Django project!

[`pip-tools`]: https://github.com/jazzband/pip-tools
[`uwsgi`]: https://uwsgi-docs.readthedocs.io/en/latest/
[`uwsgi` docs]: https://uwsgi-docs.readthedocs.io/en/latest/Options.html
[`nginx` server]: https://nginx.org/
[`certbot`]: https://certbot.eff.org/
[`django-extensions`]: https://github.com/django-extensions/django-extensions
[`pytest`]: https://docs.pytest.org/en/latest/
