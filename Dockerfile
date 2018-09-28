FROM python:3.6
WORKDIR /usr/src/app
COPY . .
ENV DEBIAN_FRONTEND noninteractive
ENV TZ Asia/Shanghai

RUN apt-get update
RUN apt-get install vim -y

RUN apt-get install -y redis-server
RUN sed -i 's/^\(bind .*\)$/# \1/' /etc/redis/redis.conf \
    && sed -i 's/^\(databases .*\)$/databases 1/' /etc/redis/redis.conf \
    && sed -i 's/^\(daemonize .*\)$/daemonize yes/' /etc/redis/redis.conf
#    && sed -i 's/^\(dir .*\)$/# \1\ndir \/data/' /etc/redis/redis.conf  \
#    && sed -i 's/^\(logfile .*\)$/# \1/' /etc/redis/redis.conf

RUN redis-server /etc/redis/redis.conf &

RUN pip install --no-cache-dir -r requirements.txt

RUN cd Run

EXPOSE 5010
CMD [ "python", "main.py" ]
