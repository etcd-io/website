DOCKER_IMG = klakegg/hugo:ext-alpine
DRAFT_ARGS = --buildDrafts --buildFuture  --buildExpired

production-build:
	npm run build:production

docker-serve:
	docker run --rm -it -v $(PWD):/src -p 1313:1313 $(DOCKER_IMG) server $(DRAFT_ARGS)

link-checker-setup:
	# https://wjdp.uk/work/htmltest/
	curl https://htmltest.wjdp.uk | bash

run-link-checker:
	bin/htmltest

check-links: production-build link-checker-setup run-link-checker

# Adding additional link checks based on https://github.com/grpc/grpc.io/blob/main/Makefile
check-internal-links: production-build link-checker-setup run-link-checker
	bin/htmltest --conf .htmltest.yml

check-all-links: production-build link-checker-setup
	bin/htmltest --conf .htmltest.external.yml
