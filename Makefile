# Args based on grcp/grpc.io's Makefile
# https://github.com/grpc/grpc.io/blob/main/Makefile

DRAFT_ARGS = --buildDrafts --buildFuture
BUILD_ARGS = --minify
ifeq (draft, $(or $(findstring draft,$(HEAD)),$(findstring draft,$(BRANCH))))
BUILD_ARGS += $(DRAFT_ARGS)
endif

clean:
	rm -rf public/* resources/*

serve:
	@./check_hugo.sh
	hugo serve

serve-drafts:
	@./check_hugo.sh
	hugo serve $(DRAFT_ARGS)

serve-production: clean
	@./check_hugo.sh
	hugo serve -e production --minify

production-build: clean
	@./check_hugo.sh
	npm ci
	hugo --minify

preview-build: clean
	npm ci
	hugo --enableGitInfo --buildFuture -b $(DEPLOY_PRIME_URL)
#	@./check_hugo.sh
#	hugo \
#		--baseURL $(DEPLOY_PRIME_URL) \
#		--buildDrafts \
#		--buildFuture \
#		--minify

link-checker-setup:
	# https://wjdp.uk/work/htmltest/
	curl https://htmltest.wjdp.uk | bash

run-link-checker:
	bin/htmltest

check-links: clean production-build link-checker-setup run-link-checker

# Adding additional link checks based on https://github.com/grpc/grpc.io/blob/main/Makefile
check-internal-links: production-build link-checker-setup run-link-checker

check-all-links: production-build link-checker-setup
	bin/htmltest --conf .htmltest.external.yml

