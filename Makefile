DOCKER_IMG = klakegg/hugo:0.53-ext
SERVER     = server --buildDrafts --buildFuture --disableFastRender --ignoreCache

setup:
	yarn

serve:
	hugo $(SERVE)

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
