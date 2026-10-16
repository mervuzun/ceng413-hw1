# HW-1 Answers

## 1. Order of Dockerfile instructions

The Dockerfile starts from a pinned base image, sets the working directory, copies only `requirements.txt` and installs the dependencies, and only then copies the application code. After that it creates a non-root user, sets environment variables, and defines the health check and start command. Docker caches each layer and reuses it as long as the layer's inputs have not changed. When I changed only a comment in `app.py` and rebuilt, the `pip install` step was marked CACHED and took 0.0 s instead of 3.9 s, and the whole build finished in 1.8 s. If I swapped the order and copied the code before installing dependencies, every small code change would invalidate the cache for the `pip install` layer, so dependencies would be downloaded and installed again on every build, making builds much slower.

## 2. Data inside a container

Data written inside a container lives in the container's writable layer, so it is deleted when the container is removed. I tested this with the `/visit` counter: it reached 3, I removed the container, started a new one, and the counter was back at 1. Then I ran the container with a named volume (`-v hw1-data:/data`); after removing and recreating the container with the same volume, the counter continued from 3. A volume keeps data outside the container's lifecycle. Important application state should be stored outside the container, in a volume or, better, in an external service such as a database, so that containers stay replaceable.

## 3. The `latest` tag

`latest` is just a moving label that points to whatever version was pushed most recently, not a fixed version. When I ran `docker run hello-world` without a tag, Docker silently pulled `hello-world:latest`. A build that works today with `latest` may break or behave differently next month because the tag points to a new image, so the same Dockerfile does not always produce the same result. I checked that `python:3.12-slim` currently points to Python 3.12.15 using `docker image inspect`, and pinned my base image to `python:3.12.15-slim` instead.

