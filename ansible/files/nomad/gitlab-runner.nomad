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
        entrypoint = ["/bin/bash", "/local/entrypoint.sh"]
        volumes = [
          "/var/run/docker.sock:/var/run/docker.sock"
         ]
      }
      env {
      }

      template {
        data = "{{ key \"gitlab/runner_ca\" }}"
        destination = "local/ca.crt"
      }

      template {
        data = <<EOH
        #!/bin/bash
        {{ if keyExists "gitlab/runner_token" }}
        gitlab-runner register --non-interactive --registration-token {{ key "gitlab/runner_token" }} \
        --executor "docker" --docker-image alpine:3 --docker-volumes /var/run/docker.sock:/var/run/docker.sock \
        --docker-privileged --url "http://gitlab/" --description "docker-runner" --run-untagged --locked="false" \
        --docker-dns=172.17.0.1 --docker-dns-search=service.consul
        cp -f /local/ca.crt /usr/local/share/ca-certificates/ca.crt
        update-ca-certificates --fresh >/dev/null
        /usr/bin/dumb-init /entrypoint run --user=gitlab-runner --working-directory=/home/gitlab-runner
        {{ else }}
        /usr/bin/dumb-init /entrypoint run --user=gitlab-runner --working-directory=/home/gitlab-runner
        {{ end }}
        EOH
        destination = "local/entrypoint.sh"
      }
      resources {
        cpu    = "200"
        memory = "150"
        network {
          mbits = 10
        }
      }
    }
  }
}

