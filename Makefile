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
	@find . -path ./.git -prune -o -type f -name '*.sh' -print | xargs shellcheck
	@shellcheck -s bash usr/local/etc/devops.bashrc

.PHONY: prune
prune:
	docker system prune -f
