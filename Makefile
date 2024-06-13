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

get-link-checker:
	rm -Rf $(HTMLTEST_DIR)/bin
	curl https://htmltest.wjdp.uk | bash -s -- -b $(HTMLTEST_DIR)/bin

clean:
	rm -rf $(HTMLTEST_DIR) public/* resources

.PHONY: update-release-version
update-release-version:
ifndef LATEST_VERSION
	@echo "LATEST_VERSION needs to be specified" && exit 1
else
	./scripts/update_release_version.sh "$(LATEST_VERSION)"
endif
