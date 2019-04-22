job "runner-job" {
  datacenters = ["dc1"]
  type = "service"
  group "runner-group" {
    count = 1
    restart {
      attempts = 2
      interval = "30m"
      delay = "15s"
      mode = "fail"
    }
    ephemeral_disk {
      size = 300
    }
    task "runner" {
      driver = "docker"
      config {
        image = "gitlab/gitlab-runner:latest"
        dns_search_domains = ["service.consul"]
        dns_servers = ["172.17.0.1", "8.8.8.8", "8.8.4.4"]
        volumes = [
          "/var/run/docker.sock:/var/run/docker.sock"
         ]
      }
      env {
      }

      template {
        data = <<EOH
        #!/bin/bash
        {{ if keyExists "gitlab/runner_token" }}
        gitlab-runner register --non-interactive --registration-token {{ key "gitlab/runner_token" }} \
        --executor "docker" --docker-image alpine:3 --docker-volumes /var/run/docker.sock:/var/run/docker.sock \
        --docker-privileged --url "http://gitlab-reg/" --description "docker-runner" --run-untagged --locked "false"
        exec /entrypoint "$@"
        {{ else }}
        exec /entrypoint "$@"
        {{ end }}
        EOH
        destination = "local/entrypoint.sh"
      }



      resources {
        network {
          mbits = 10
        }
      }
    }
  }
}

