#!/bin/sh

DIR="$XDG_CONFIG_HOME/coc/extensions/coc-pydocstring-data/doq"

mkdir -p $DIR

(
	cd $DIR
	python -m venv --prompt doq venv
	source venv/bin/activate
	pip install --upgrade pip
	pip install --upgrade doq
)
