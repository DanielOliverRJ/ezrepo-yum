FROM centos:7
MAINTAINER "ezrepo" <ezrepo@gmail.com>

RUN yum -y update &&\
    yum -y install epel-release &&\
    yum -y install yum-utils createrepo crudini deltarpm &&\
    yum clean all &&\
    mkdir -p /var/www/repos/latest &&\
    mkdir -p /etc/ezrepo

COPY ezrepo-yum.sh /bin/

ENTRYPOINT ["/bin/ezrepo-yum.sh"]
CMD [""]
