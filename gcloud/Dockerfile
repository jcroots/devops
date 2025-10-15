FROM gcr.io/google.com/cloudsdktool/google-cloud-cli:stable

LABEL maintainer="Jeremías Casteglione <jeremias.rootstrap@gmail.com>"
LABEL version="251014"

USER root:root
WORKDIR /root

ENV USER=root
ENV HOME=/root

COPY root/bin /root/bin

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get clean \
	&& apt-get update -yy \
	&& apt-get dist-upgrade -yy --purge \
	&& rm -rf /var/lib/apt/lists/* \
		/var/cache/apt/archives/*.deb \
		/var/cache/apt/*cache.bin

ENV APT_INSTALL='bash bash-completion openssl ca-certificates media-types less wget unzip'

RUN /root/bin/apt-install.sh ${APT_INSTALL}

RUN groupadd -g 1980 devops \
	&& useradd -d /home/devops -m -c devops -g 1980 -u 1980 devops \
	&& chmod -v 0750 /home/devops

RUN printf 'umask %s\n' '027' >>/home/devops/.profile
RUN printf "export PS1='%s '\n" '\u@\h:\W\$' >>/home/devops/.profile

RUN ln -vs /usr/lib/google-cloud-sdk/bin/gcloud /usr/local/bin/gcloud
RUN ln -vs /usr/lib/google-cloud-sdk/bin/gsutil /usr/local/bin/gsutil

ENV TF_VERSION=1.13.3
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
