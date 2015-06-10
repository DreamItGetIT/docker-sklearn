.PHONY: package push-package

package:
	@docker build -t docker.dreamitget.it/sklearn .

push-package:
	@docker push docker.dreamitget.it/sklearn
