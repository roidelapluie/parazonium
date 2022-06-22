package main

import (
	"dagger.io/dagger"

	"dagger.io/dagger/core"
	"universe.dagger.io/docker"
)

_builder: docker.#Pull & {
    source: "quay.io/prometheus/golang-builder:1.18-base"
}

#build: docker.#Run & {
	_cmd:  string
	input: _builder.output
	entrypoint: ["/bin/bash", "-c"]
	command: {name: _cmd}
	env: {
		GOMODCACHE:       _modCachePath
		npm_config_cache: _npmCachePath
	}
	_modCachePath:   "/go-mod-cache"
	_buildCachePath: "/go-build-cache"
	_npmCachePath:   "/npm-build-cache"
	mounts: {
		"app": {
			"dest":     "/app"
			"contents": source.output
		}
		"go mod cache": {
			contents: core.#CacheDir & {
				id: "go_mod"
			}
			dest: _modCachePath
		}
		"npm cache": {
			contents: core.#CacheDir & {
				id: "npm"
			}
			dest: _npmCachePath
		}
		"go build cache": {
			contents: core.#CacheDir & {
				id: "go_build"
			}
			dest: _buildCachePath
		}
	}
	workdir: "/app"
}
