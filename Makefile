load-docs:
	scripts/load-docs.sh

serve: load-docs
	hugo server \
		--buildDrafts \
		--buildFuture \
		--disableFastRender \
		--ignoreCache

production-build: load-docs
	hugo --minify

preview-build: load-docs
	hugo \
		--baseURL $(DEPLOY_PRIME_URL) \
		--buildDrafts \
		--buildFuture \
		--minify
