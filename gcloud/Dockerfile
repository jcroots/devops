FROM gcr.io/google.com/cloudsdktool/google-cloud-cli:stable

LABEL maintainer="Jeremías Casteglione <jeremias.rootstrap@gmail.com>"
LABEL version="251014"

USER root:root
WORKDIR /root

ENV USER=root
ENV HOME=/root

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get clean \
	&& apt-get update -yy \
	&& apt-get dist-upgrade -yy --purge \
	&& rm -rf /var/lib/apt/lists/* \
		/var/cache/apt/archives/*.deb \
		/var/cache/apt/*cache.bin

COPY root/bin/apt-install.sh /root/bin/apt-install.sh

COPY root/etc/apt.install /root/etc/apt.install
RUN cat /root/etc/apt.install | xargs /root/bin/apt-install.sh

RUN groupadd -g 1980 devops \
	&& useradd -d /home/devops -m -c devops -g 1980 -u 1980 devops \
	&& chmod -v 0750 /home/devops

RUN printf 'umask %s\n' '0027' >>/home/devops/.profile

RUN ln -vs /usr/lib/google-cloud-sdk/bin/gcloud /usr/local/bin/gcloud
RUN ln -vs /usr/lib/google-cloud-sdk/bin/gsutil /usr/local/bin/gsutil

COPY root/bin/terraform-install.sh /root/bin/terraform-install.sh
RUN /root/bin/terraform-install.sh

COPY gcloud/user-login.sh /usr/local/bin/user-login.sh
RUN chmod -v 0755 /usr/local/bin/user-login.sh

USER devops:devops
WORKDIR /home/devops

ENV USER=devops
ENV HOME=/home/devops

RUN gcloud version
RUN terraform version

ENTRYPOINT ["/bin/bash", "-i", "-l"]
