<p align="center">
  <img src="https://curl.se/logo/curl-logo.svg" width="256" alt="" />
</p>

> [!WARNING]
> This repository is no longer maintained. The reason is quite simple - the main purpose of this image was to
> provide a static binary of `curl` for use in `scratch`-based images as a healthcheck, but in my opinion,
> `curl` is too large for this purpose (~6 MB). Instead of this image, I recommend using [microcheck][microcheck],
> a tiny (~75 KB, in **80 times smaller**) HTTP healthcheck utility with some additional features, developed by me.
>
> To avoid breaking existing integrations, the Docker image will remain available on both Docker Hub and GitHub
> Container Registry, but no further updates will be made.
>
> GG;HF!

[microcheck]:https://github.com/tarampampam/microcheck

# Docker image with [curl][link_curl]

[![Build Status][badge_build_status]][link_build_status]
[![Release Status][badge_release_status]][link_build_status]
[![Image size][badge_size_latest]][link_docker_hub]
[![Docker Pulls][badge_docker_pulls]][link_docker_hub]
[![License][badge_license]][link_license]

## Why was this image created?

As you may know, `curl` comprises two components: the library with the same name and a dynamically linked executable
file. When using `curl` in Docker images based on `scratch` (empty file system), we have two options:

- Include all required libraries for `curl` in the image.
- Compile `curl` as a **static** binary.

This repository contains a Dockerfile using the second approach (the main idea was found [here](https://github.com/moparisthebest/static-curl)).

> Important note: Some `curl` features (such as `gopher`, `imap`, `proxy`, and others) have been disabled for binary
> file size reasons.

Another important change is that when the `--fail` flag is used, the exit code on error is **1** (instead of 22). You
can find more details about the patch [here](patches/fail-exit-code.patch). This change was made for use in Docker
health checks (the possible exit codes for Docker health checks are: 0 for success, indicating the container is
healthy and ready for use, and 1 for unhealthy, indicating the container is not working correctly):

```bash
$ docker run --rm tarampampam/curl -s --fail --show-error https://httpbin.org/status/401
curl: (22) The requested URL returned error: 401

$ echo "Exit code: $?"
Exit code: 1
```

## Image

| Registry                                            | Image                      |
|-----------------------------------------------------|----------------------------|
| [GitHub Container Registry][link_github_containers] | `ghcr.io/tarampampam/curl` |
| [Docker Hub][link_docker_tags]                      | `tarampampam/curl`         |

> Images, based on the `alpine` image has a postfix `-alpine` in the tag name, e.g.: `tarampampam/curl:8.0.1-alpine`.

Following platforms for this image are available:

```bash
$ docker run --rm mplatform/mquery tarampampam/curl:latest
Image: tarampampam/curl:latest
 * Manifest List: Yes (Image type: application/vnd.docker.distribution.manifest.list.v2+json)
 * Supported platforms:
   - linux/amd64
   - linux/386
   - linux/arm64
   - linux/arm/v6
   - linux/arm/v7
```

## How can I use this?

For example - as a docker healthcheck (note - we use `scratch` as a base):

```Dockerfile
# use empty filesystem
FROM scratch

# import some executable application
COPY --from=docker.io/containous/whoami:v1.5.0 /whoami /whoami

# import curl from current repository image
COPY --from=ghcr.io/tarampampam/curl:8.6.0 /bin/curl /bin/curl

# Docs: <https://docs.docker.com/engine/reference/builder/#healthcheck>
HEALTHCHECK --interval=5s --timeout=2s --retries=2 --start-period=2s CMD [ \
    "curl", "--fail", "http://127.0.0.1:80/" \
]

ENTRYPOINT ["/whoami"]
```

After that you can build this image, run, and watch the state:

```bash
$ docker build --tag healthcheck-test:local .
...
Successfully built 72bf22424af7
Successfully tagged healthcheck-test:local

$ docker run --rm -d --name healthcheck-test healthcheck-test:local
b3f20332ac19b42dfed03021c0b90b3650b9a7efbaea7c8800d35551e43d35d7

$ docker ps --filter 'name=healthcheck-test' --format '{{.Status}}'
Up 1 minutes (healthy)

$ docker kill healthcheck-test
```

## Releasing

New versions publishing is very simple - just make required changes in this repository and "publish" new release using
repo releases page.

Docker images will be build and published automatically.

> The new release will overwrite the `latest` and `latest-alpine` docker image tags in both registers.

## Support

[![Issues][badge_issues]][link_issues]
[![Issues][badge_pulls]][link_pulls]

If you find any package errors, please, [make an issue][link_create_issue] in current repository.

## License

WTFPL. Use anywhere for your pleasure.

[badge_build_status]:https://img.shields.io/github/actions/workflow/status/tarampampam/curl-docker/tests.yml?branch=master&logo=github&label=build
[badge_release_status]:https://img.shields.io/github/actions/workflow/status/tarampampam/curl-docker/release.yml?logo=github&label=release
[badge_issues]:https://img.shields.io/github/issues/tarampampam/curl-docker.svg?style=flat-square&maxAge=180
[badge_pulls]:https://img.shields.io/github/issues-pr/tarampampam/curl-docker.svg?style=flat-square&maxAge=180
[badge_license]:https://img.shields.io/github/license/tarampampam/curl-docker.svg?longCache=true
[badge_size_latest]:https://img.shields.io/docker/image-size/tarampampam/curl/latest?maxAge=30
[badge_docker_pulls]:https://img.shields.io/docker/pulls/tarampampam/curl.svg
[link_issues]:https://github.com/tarampampam/curl-docker/issues
[link_pulls]:https://github.com/tarampampam/curl-docker/pulls
[link_build_status]:https://github.com/tarampampam/curl-docker/actions
[link_create_issue]:https://github.com/tarampampam/curl-docker/issues/new
[link_license]:https://github.com/tarampampam/curl-docker/blob/master/LICENSE
[link_docker_tags]:https://hub.docker.com/r/tarampampam/curl/tags
[link_docker_hub]:https://hub.docker.com/r/tarampampam/curl/
[link_github_containers]:https://github.com/tarampampam/curl-docker/pkgs/container/curl
[link_curl]:https://curl.se/
