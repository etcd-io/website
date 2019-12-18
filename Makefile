DOCKER_IMG = klakegg/hugo:0.60.1-ext
SERVER     = server --buildDrafts --buildFuture --disableFastRender --ignoreCache

setup:
	yarn

serve:
	hugo $(SERVER)

docker-serve:
	docker run --rm -it -v $(PWD):/src -p 1313:1313 $(DOCKER_IMG) $(SERVER)

docker-serve:

production-build:
	hugo --minify

preview-build:
	hugo \
		--baseURL $(DEPLOY_PRIME_URL) \
		--buildDrafts \
		--buildFuture \
		--minify
