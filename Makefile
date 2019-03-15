load-docs:
	scripts/load-docs.sh

serve:
	hugo server \
		--buildDrafts \
		--buildFuture \
		--disableFastRender \
		--ignoreCache

production-build:
	hugo --minify

preview-build:
	hugo \
		--baseURL $(DEPLOY_PRIME_URL) \
		--buildDrafts \
		--buildFuture \
		--minify
