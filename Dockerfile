FROM centos:latest

ENV TZ=Asia/Shanghai
RUN sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
RUN sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*
RUN yum makecache
RUN yum update -y
RUN yum install -y epel-release https://packages.endpointdev.com/rhel/8/main/x86_64/endpoint-repo.noarch.rpm && yum install -y --setopt=tsflags=nodocs nginx redis mariadb-server mariadb-devel python39 python39-devel openldap-devel git gcc wget rsync net-tools && yum -y clean all --enablerepo='*'


RUN pip3 install --no-cache-dir --upgrade pip -i https://mirrors.aliyun.com/pypi/simple/
RUN pip3 install --no-cache-dir -i https://mirrors.aliyun.com/pypi/simple/ \
    gunicorn \
	supervisor \
    mysqlclient \
    cryptography==36.0.2 \
    apscheduler==3.7.0 \
    asgiref==3.2.10 \
    Django==2.2.28 \
    channels==2.3.1 \
    channels_redis==2.4.1 \
    paramiko==2.11.0 \
    django-redis==4.10.0 \
    requests==2.22.0 \
    GitPython==3.0.8 \
    python-ldap==3.4.0 \
    openpyxl==3.0.3 \
    user_agents==2.2.0

ENV LANG=en_US.UTF-8
RUN echo -e '\n# Source definitions\n. /etc/profile\n' >> /root/.bashrc
RUN mkdir /data
COPY init_spug /usr/bin/
COPY nginx.conf /etc/nginx/
COPY ssh_config /etc/ssh/
COPY spug.ini /etc/supervisord.d/
COPY my.cnf /etc/
COPY redis.conf /etc/
COPY supervisord.conf /etc/
COPY entrypoint.sh /
COPY spug.tar.gz /tmp/
RUN chmod +x /entrypoint.sh
RUN mkdir -p /var/run/supervisor

VOLUME /data
EXPOSE 80
ENTRYPOINT ["/entrypoint.sh"]
