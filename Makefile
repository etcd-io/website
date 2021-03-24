DOCKER_IMG = klakegg/hugo:0.81.0-ext-asciidoctor
SERVER     = server --buildDrafts --buildFuture --disableFastRender --ignoreCache

setup:
	npm install

serve:
	hugo $(SERVER)

docker-serve:
	docker run --rm -it -v $(PWD):/src -p 1313:1313 $(DOCKER_IMG) $(SERVER)

production-build:
	hugo --minify

preview-build:
	hugo \
		--baseURL $(DEPLOY_PRIME_URL) \
		--buildDrafts \
		--buildFuture \
		--minify

clean:
	rm -rf public

link-checker-setup:
	# https://wjdp.uk/work/htmltest/
	curl https://htmltest.wjdp.uk | bash

run-link-checker:
	bin/htmltest

check-links: clean production-build link-checker-setup run-link-checker

