#!/bin/bash
gitlab-runner register --non-interactive --registration-token=4Ja_8bmhsJbpx7gAY8x3 --executor "docker" --docker-image alpine:3 --docker-volumes /var/run/docker.sock:/var/run/docker.sock --docker-privileged --url "http://gitlab-reg/" --description "docker-runner" --run-untagged --locked "false"
