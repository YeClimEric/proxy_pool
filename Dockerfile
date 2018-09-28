FROM python:3.6
WORKDIR /usr/src/app
COPY . .
ENV DEBIAN_FRONTEND noninteractive
ENV TZ Asia/Shanghai
RUN apt-get update \
    && apt-get install -y --no-install-recommends apt-utils \
	&& apt-get install -y redis-server \
	&& pip install --no-cache-dir -r requirements.txt \
    && sed -i 's/^\(bind .*\)$/# \1/' /etc/redis/redis.conf \
    && sed -i 's/^\(daemonize .*\)$/daemonize yes/' /etc/redis/redis.conf  \
    && sed -i 's/^\(dir .*\)$/# \1\ndir \/data/' /etc/redis/redis.conf  \
    && sed -i 's/^\(logfile .*\)$/# \1/' /etc/redis/redis.conf \
	&& echo "# ! /bin/sh " > /usr/src/app/run.sh \
	&& echo "cd Run" >> /usr/src/app/run.sh \
	&& echo "/usr/bin/redis-server /etc/redis/redis.conf &" >> /usr/src/app/run.sh \
	&& echo "python main.py" >> /usr/src/app/run.sh  \
	&& chmod 777 run.sh
EXPOSE 5010
CMD [ "sh", "run.sh" ]
