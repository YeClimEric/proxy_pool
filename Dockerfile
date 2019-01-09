FROM python:3.6
MAINTAINER yeclimeric@gmail.com
WORKDIR /usr/src/app
COPY . .
ENV DEBIAN_FRONTEND noninteractive
ENV TZ Asia/Shanghai

RUN apt-get update
RUN apt-get install apt-utils -y
# RUN apt-get install vim -y
RUN apt-get install -y nodejs npm
RUN apt-get install -y redis-server

RUN sed -i 's/^\(bind .*\)$/# \1/' /etc/redis/redis.conf \
    && sed -i 's/^\(databases .*\)$/databases 1/' /etc/redis/redis.conf \
    && sed -i 's/^\(daemonize .*\)$/daemonize yes/' /etc/redis/redis.conf
#    && sed -i 's/^\(dir .*\)$/# \1\ndir \/data/' /etc/redis/redis.conf  \
#    && sed -i 's/^\(logfile .*\)$/# \1/' /etc/redis/redis.conf

RUN pip install --no-cache-dir -r requirements.txt
RUN npm install

RUN echo "# ! /bin/sh " > run.sh \
    && echo "redis-server /etc/redis/redis.conf&" >> run.sh \
	&& echo "cd Schedule" >> run.sh \
#	&& echo "nohup python ProxyCheck.py  &" >> run.sh  \
	&& echo "nohup python ProxyRefreshSchedule.py &" >> run.sh  \
	&& echo "nohup python ProxyValidSchedule.py &" >> run.sh  \
	&& echo "cd ../Api" >> run.sh \
	&& echo "nohup node server.js &" >> run.sh  \
	&& echo "tail -f /dev/null" >> run.sh  \
	&& chmod 777 run.sh

EXPOSE 5010
CMD [ "sh", "run.sh" ]
