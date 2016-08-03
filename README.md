# osixia/cfssl-multirootca

[![Docker Pulls](https://img.shields.io/docker/pulls/osixia/cfssl-multirootca.svg)][hub]
[![Docker Stars](https://img.shields.io/docker/stars/osixia/cfssl-multirootca.svg)][hub]
[![Image Size](https://img.shields.io/imagelayers/image-size/osixia/cfssl-multirootca/latest.svg)](https://imagelayers.io/?images=osixia/cfssl-multirootca:latest)
[![Image Layers](https://img.shields.io/imagelayers/layers/osixia/cfssl-multirootca/latest.svg)](https://imagelayers.io/?images=osixia/cfssl-multirootca:latest)

[hub]: https://hub.docker.com/r/osixia/cfssl-multirootca/

Latest release: 0.1.2 - cfssl multirootca 1.2.0 - [Changelog](CHANGELOG.md) | [Docker Hub](https://hub.docker.com/r/osixia/cfssl-multirootca/) 


A docker image to run cfssl multirootca tool.
> https://github.com/cloudflare/cfssl


- [Beginner Guide](#beginner-guide)
	- [Use your own config](#use-your-own-config)
	- [HTTPS](#https)
		- [Use autogenerated certificate](#use-autogenerated-certificate)
		- [Use your own certificate](#use-your-own-certificate)
	- [Fix docker mounted file problems](#fix-docker-mounted-file-problems)
	- [Debug](#debug)
- [Environment Variables](#environment-variables)
	- [Set your own environment variables](#set-your-own-environment-variables)
		- [Use command line argument](#use-command-line-argument)
		- [Link environment file](#link-environment-file)
		- [Make your own image or extend this image](#make-your-own-image-or-extend-this-image)
- [Advanced User Guide](#advanced-user-guide)
	- [Extend osixia/cfssl-multirootca:0.1.2 image](#extend-osixiacfssl-multirootca012-image)
	- [Make your own cfssl-multirootca image](#make-your-own-cfssl-multirootca-image)
	- [Tests](#tests)
	- [Under the hood: osixia/light-baseimage](#under-the-hood-osixialight-baseimage)
- [Changelog](#changelog)

## Beginner Guide

### Use your own config
This image comes with a roots config file that can be easily customized via environment variables for a quick bootstrap,
but setting your own roots.conf is possible. 2 options:

- Link your config file at run time to `/container/service/multirootca/assets/roots.conf` and the  corresponding needed files to `/container/service/multirootca/assets/files`:

      docker run --volume /data/my-roots.conf:/container/service/multirootca/assets/roots.conf --volume /data/files:/container/service/multirootca/assets/files --detach osixia/multirootca:0.1.2

- Add your config file by extending or cloning this image, please refer to the [Advanced User Guide](#advanced-user-guide)

### HTTPS

By default HTTPS is disable.

#### Use autogenerated certificate
Add `--env CFSSL_MUTLTIROOTCA_HTTPS=true` to run command then a certificate is created with the container hostname (it can be set by docker run --hostname option eg: pki.my-company.com).

	docker run --env CFSSL_MUTLTIROOTCA_HTTPS=true --hostname pki.my-company.com --detach osixia/cfssl-multirootca:0.1.2

#### Use your own certificate

You can set your custom certificate at run time, add `--env CFSSL_MUTLTIROOTCA_HTTPS=true`, mount a directory containing those files to **/container/service/multirootca/assets/certs** and adjust their name with the following environment variables:

		docker run --env CFSSL_MUTLTIROOTCA_HTTPS=true \
		--volume /path/to/certifates:/container/service/multirootca/assets/certs \
		--env CFSSL_MUTLTIROOTCA_HTTPS_CRT_FILENAME=my.crt \
		--env CFSSL_MUTLTIROOTCA_HTTPS_KEY_FILENAME=my.key \
		--detach osixia/cfssl-multirootca:0.1.2

Other solutions are available please refer to the [Advanced User Guide](#advanced-user-guide)

### Fix docker mounted file problems

You may have some problems with mounted files on some systems. The startup script try to make some file adjustment and fix files owner and permissions, this can result in multiple errors. See [Docker documentation](https://docs.docker.com/v1.4/userguide/dockervolumes/#mount-a-host-file-as-a-data-volume).

To fix that run the container with `--copy-service` argument :

		docker run [your options] osixia/cfssl-multirootca:0.1.2 --copy-service

### Debug

The container default log level is **info**.
Available levels are: `none`, `error`, `warning`, `info`, `debug` and `trace`.

Example command to run the container in `debug` mode:

	docker run --detach osixia/cfssl-multirootca:0.1.2 --loglevel debug

See all command line options:

	docker run osixia/cfssl-multirootca:0.1.2 --help


## Environment Variables

Environment variables defaults are set in **image/environment/default.yaml**

See how to [set your own environment variables](#set-your-own-environment-variables)

- **CFSSL_MULTIROOTCA_ROOTS**: Set multirootca config. Defaults to :

  ```yaml
  - primary:
    - private: file://testdata/server.key
    - certificate: testdata/server.crt
    - config: testdata/config.json
    - nets: 10.0.2.1/24,172.16.3.1/24, 192.168.3.15/32
  - backup:
    - private: file://testdata/server.key
    - certificate: testdata/server.crt
    - config: testdata/config.json
  ```
  This will be converted in the roots.conf file to :
  ```
  [ primary ]
  private = file://testdata/server.key
  certificate = testdata/server.crt
  config = testdata/config.json
  nets = 10.0.2.1/24,172.16.3.1/24, 192.168.3.15/32
  [ backup ]
  private = file://testdata/server.key
  certificate = testdata/server.crt
  config = testdata/config.json
  ```
  All config are possible just add the needed entries.

  If you want to set this variable at docker run command add the tag `#PYTHON2BASH:` and convert the yaml in python:

		docker run --env CFSSL_MULTIROOTCA_ROOTS="#PYTHON2BASH:[{'primary':[{'private':'file://testdata/server.key'},{'certificate':'testdata/server.crt'},{'config': 'testdata/config.json'},{'nets': '10.0.2.1/24,172.16.3.1/24, 192.168.3.15/32'}]},{'backup': [{'private': 'file://testdata/server.key'},{'certificate': 'testdata/server.crt'},{'config':'testdata/config.json'}]" --detach osixia/cfssl-multirootca:0.1.2

  To convert yaml to python online: http://yaml-online-parser.appspot.com/

- **CFSSL_MULTIROOTCA_DEFAULT_LABEL**: Server default label. Defaults to ``

HTTPS :
- **CFSSL_MUTLTIROOTCA_HTTPS**: Use https. Defaults to `false`
- **CFSSL_MUTLTIROOTCA_HTTPS_CRT_FILENAME**: SSL certificate filename. Defaults to `cfssl-mutlirootca.crt`
- **CFSSL_MUTLTIROOTCA_HTTPS_KEY_FILENAME**: SSL certificate private key filename. Defaults to `cfssl-mutlirootca.key`

Other configuration:

- **CFSSL_MULTIROOTCA_LOGLEVEL**: Enable ldap client tls config, ldap serveur certificate check and set client  certificate. Defaults to `true`
- **CFSSL_MULTIROOTCA_SSL_HELPER_PREFIX**: ssl-helper environment variables prefix. Defaults to `multirootca`, ssl-helper first search config from MUTLTIROOTCA_SSL_HELPER_* variables, before SSL_HELPER_* variables.

### Set your own environment variables

#### Use command line argument
Environment variables can be set by adding the --env argument in the command line, for example:

	docker run --env CFSSL_MUTLTIROOTCA_HTTPS="true" \
	--detach osixia/cfssl-multirootca:0.1.2

#### Link environment file

For example if your environment file is in :  `/data/environment/my-env.yaml`

	docker run --volume /data/environment/my-env.yaml:/container/environment/01-custom/env.yaml \
	--detach osixia/cfssl-multirootca:0.1.2

Take care to link your environment file to `/container/environment/XX-somedir` (with XX < 99 so they will be processed before default environment files) and not  directly to `/container/environment` because this directory contains predefined baseimage environment files to fix container environment (INITRD, LANG, LANGUAGE and LC_CTYPE).

#### Make your own image or extend this image

This is the best solution if you have a private registry. Please refer to the [Advanced User Guide](#advanced-user-guide) just below.

## Advanced User Guide

### Extend osixia/cfssl-multirootca:0.1.2 image

If you need to add your custom TLS certificate, bootstrap config or environment files the easiest way is to extends this image.

Dockerfile example:

    FROM osixia/cfssl-multirootca:0.1.2
    MAINTAINER Your Name <your@name.com>

    ADD https-certs /container/service/multiroot/assets/certs
    ADD ca-files /container/service/multiroot/assets/files
    ADD environment /container/environment/01-custom


### Make your own cfssl-multirootca image

Clone this project :

	git clone https://github.com/osixia/docker-cfssl-multirootca
	cd docker-cfssl-multirootca

Adapt Makefile, set your image NAME and VERSION, for example :

	NAME = osixia/cfssl-multirootca
	VERSION = 0.1.2

	becomes :
	NAME = billy-the-king/cfssl-multirootca
	VERSION = 0.1.0

Add your custom certificate and environment files...

Build your image :

	make build

Run your image :

	docker run -d billy-the-king/cfssl-multirootca:0.1.2

### Tests

We use **Bats** (Bash Automated Testing System) to test this image:

> [https://github.com/sstephenson/bats](https://github.com/sstephenson/bats)

Install Bats, and in this project directory run :

	make test

### Under the hood: osixia/light-baseimage

This image is based on osixia/web-baseimage.
More info: https://github.com/osixia/docker-light-baseimage

## Changelog

Please refer to: [CHANGELOG.md](CHANGELOG.md)
