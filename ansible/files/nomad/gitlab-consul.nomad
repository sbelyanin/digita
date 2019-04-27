job "gitlabl-consul" {
  datacenters = ["dc1"]
  type = "batch"
  constraint {
    attribute = "${attr.platform.gce.attr.gitlab}"
    value     = "True"
  }
  group "gitlab-consul" {
    count = 1
    restart {
      attempts = 5
      interval = "10m"
      delay = "30s"
      mode = "delay"
    }

    task "gitlab-consul-token" {
      driver = "raw_exec"
      config {
        command = "/bin/bash"
        args = ["-c", "TOKEN=$(docker exec `docker ps -q -f \"name=gitlab\"` gitlab-rails runner -e production \"puts Gitlab::CurrentSettings.current_application_settings.runners_registration_token\") && consul kv put gitlab/runner_token \"$TOKEN\""]
      }
      resources {
        cpu    = 100 # Mhz
        memory = 100  # MB
        network {
          mbits = 10
          port "uptime1" {}
        }
      }
    }

    task "gitlab-consul-CA" {
      driver = "raw_exec"
      config {
        command = "/bin/bash"
        args = ["-c", "CA=$(cat \"/srv/certs/CA.crt\") && consul kv put gitlab/runner_ca \"$CA\""]
      }
      resources {
        cpu    = 100 # Mhz
        memory = 100  # MB
        network {
          mbits = 10
          port "uptime2" {}
        }
      }
    }
  }
}

