.PHONY: all

all:
	./build.sh aws
	./build.sh gcloud

.PHONY: check
check:
	@shellcheck *.sh */*.sh */*/*.sh
