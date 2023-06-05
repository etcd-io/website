DOCKER_IMG = klakegg/hugo:ext-alpine
DRAFT_ARGS = --buildDrafts --buildFuture  --buildExpired

HTMLTEST?=htmltest # Specify as make arg if different
HTMLTEST_ARGS?=--skip-external
HTMLTEST_DIR=tmp

# Use $(HTMLTEST) in PATH, if available; otherwise, we'll get a copy
ifeq (, $(shell which $(HTMLTEST)))
override HTMLTEST=$(HTMLTEST_DIR)/bin/htmltest
ifeq (, $(shell which $(HTMLTEST)))
GET_LINK_CHECKER_IF_NEEDED=get-link-checker
endif
endif

check-links: $(GET_LINK_CHECKER_IF_NEEDED)
	$(HTMLTEST) $(HTMLTEST_ARGS)

docker-serve:
	docker run --rm -it -v $(PWD):/src -p 1313:1313 $(DOCKER_IMG) server $(DRAFT_ARGS)

get-link-checker:
	rm -Rf $(HTMLTEST_DIR)/bin
	curl https://htmltest.wjdp.uk | bash -s -- -b $(HTMLTEST_DIR)/bin
