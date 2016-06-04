FROM ubuntu:14.04
MAINTAINER Xiaoqi Cao <thomascxq@gmail.com>

#Install Mysql 5.5

RUN groupadd -r mysql && useradd -r -g mysql mysql

RUN apt-get update -qqy
RUN DEBIAN_FRONTEND=noninteractive apt-get install -qqy mysql-server-5.5 \
  && rm -rf /var/lib/mysql && mkdir -p /var/lib/mysql /var/run/mysqld \
  && chown -R mysql:mysql /var/lib/mysql /var/run/mysqld \
  && chmod 777 /var/run/mysqld

ADD mysql/conf.d/my.cnf /etc/mysql/conf.d/my.cnf

VOLUME /var/lib/mysql

COPY bin/docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

EXPOSE 3306

CMD ["mysqld"]
