bin_file := ${HOME}/.local/bin/devenv

.PHONY: container
container:
	./build_scripts/start_container.sh

.PHONY: image
image:
	./build_scripts/build_image.sh

.PHONY: bin
bin: ${bin_file}

${bin_file}: build_scripts/start_container.sh
	ln -si $(abspath $<) $@
	chmod +x $@

install.sh: build_scripts/make_installer.sh
	./$<

.PHONY: devenv.tar
devenv.tar: build_scripts/make_wsl_image.sh image
	./$<

.PHONY: wsl
wsl: devenv.tar
