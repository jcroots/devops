.PHONY: all

all:
	$(MAKE) -j2 aws gcloud

.PHONY: aws
aws:
	./build.sh aws

.PHONY: gcloud
gcloud:
	./build.sh gcloud

.PHONY: check
check:
	@shellcheck *.sh */*.sh */*/*.sh
