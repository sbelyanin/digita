#!/bin/bash
TOKEN=$(docker exec `docker ps -q -f "name=gitlab"` gitlab-rails runner -e production "puts Gitlab::CurrentSettings.current_application_settings.runners_registration_token") && consul kv put gitlab/runner_token "$TOKEN"
