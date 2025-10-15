.PHONY: all

all:
	./build.sh gcloud

.PHONY: check
check:
	@shellcheck *.sh */*.sh */*/*.sh
