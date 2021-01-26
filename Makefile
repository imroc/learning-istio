SHELL := /bin/bash

.PHONY: deploy
deploy:
	./deploy.sh

.PHONY: p
p:
	hugo serve -b "/"