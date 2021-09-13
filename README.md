<p align="center">
  <img src="https://curl.se/logo/curl-logo.svg" width="256" alt="" />
</p>

# Docker image with [curl][link_curl]

[![Build Status][badge_build_status]][link_build_status]
[![Release Status][badge_release_status]][link_build_status]
[![Image size][badge_size_latest]][link_docker_hub]
[![Docker Pulls][badge_docker_pulls]][link_docker_hub]
[![License][badge_license]][link_license]

## Why this image created?

As you probably know, `curl` consists of two parts - the library of the same name and dynamically linked executable file. For using `curl` in docker images based on `scratch` (empty file system) we have two options:

- Put all required for `curl` libraries into the image
- Compile `curl` as a static binary

This repository contains dockerfile with the second way.

> Important note: some `curl` features (lake `gopher`, `imap`, `proxy`, and others were disabled) for binary file size reasons.

The main idea was [looked here](https://github.com/moparisthebest/static-curl).

## Supported tags

[![image stats](https://dockeri.co/image/tarampampam/curl)][link_docker_tags]

All supported image tags [can be found here][link_docker_tags].

## How can I use this?

For example:

```Dockerfile
# ...WIP...
```

## Releasing

New versions publishing is very simple - just make required changes in this repository, update the [changelog file](CHANGELOG.md) and "publish" new release using repo releases page.

Docker images will be build and published automatically.

> New release will overwrite the `latest` docker image tag in both registers.

## Changes log

[![Release date][badge_release_date]][link_releases]
[![Commits since latest release][badge_commits_since_release]][link_commits]

Changes log can be [found here][link_changes_log].

## Support

[![Issues][badge_issues]][link_issues]
[![Issues][badge_pulls]][link_pulls]

If you will find any package errors, please, [make an issue][link_create_issue] in current repository.

## License

WTFPL. Use anywhere for your pleasure.

[badge_build_status]:https://img.shields.io/github/workflow/status/tarampampam/curl-docker/tests/master?logo=github&label=build
[badge_release_status]:https://img.shields.io/github/workflow/status/tarampampam/curl-docker/release?logo=github&label=release
[badge_release_date]:https://img.shields.io/github/release-date/tarampampam/curl-docker.svg?style=flat-square&maxAge=180
[badge_commits_since_release]:https://img.shields.io/github/commits-since/tarampampam/curl-docker/latest.svg?style=flat-square&maxAge=180
[badge_issues]:https://img.shields.io/github/issues/tarampampam/curl-docker.svg?style=flat-square&maxAge=180
[badge_pulls]:https://img.shields.io/github/issues-pr/tarampampam/curl-docker.svg?style=flat-square&maxAge=180
[badge_license]:https://img.shields.io/github/license/tarampampam/curl-docker.svg?longCache=true
[badge_size_latest]:https://img.shields.io/docker/image-size/tarampampam/curl/latest?maxAge=30
[badge_docker_pulls]:https://img.shields.io/docker/pulls/tarampampam/curl.svg
[link_releases]:https://github.com/tarampampam/curl-docker/releases
[link_commits]:https://github.com/tarampampam/curl-docker/commits
[link_changes_log]:https://github.com/tarampampam/curl-docker/blob/master/CHANGELOG.md
[link_issues]:https://github.com/tarampampam/curl-docker/issues
[link_pulls]:https://github.com/tarampampam/curl-docker/pulls
[link_build_status]:https://github.com/tarampampam/curl-docker/actions
[link_create_issue]:https://github.com/tarampampam/curl-docker/issues/new
[link_license]:https://github.com/tarampampam/curl-docker/blob/master/LICENSE
[link_docker_tags]:https://hub.docker.com/r/tarampampam/curl/tags
[link_docker_hub]:https://hub.docker.com/r/tarampampam/curl/
[link_curl]:https://curl.se/
