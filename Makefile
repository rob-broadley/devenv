bin_file := ${HOME}/.local/bin/devenv

.PHONY: container
container:
	./build_scripts/start_container.sh

.PHONY: image
image:
	docker-compose build devenv

.PHONY: bin
bin: ${bin_file}

${bin_file}: build_scripts/start_container.sh
	ln -si $(abspath $<) $@
	chmod +x $@

install.sh: build_scripts/make_installer.sh
	./$<
