job "fluentd-make-job" {
  datacenters = ["dc1"]
  type = "batch"
  group "fluentd-make-group" {
    count = 1
    restart {
      attempts = 3
      delay    = "20s"
      mode     = "delay"
    }
    task "fluentd-make-task" {
      template {
        data = <<EOH
FROM fluent/fluentd
RUN gem install fluent-plugin-elasticsearch --no-rdoc --no-ri
RUN gem install fluent-plugin-grok-parser --no-rdoc --no-ri
EOH
        destination = "local/Dockerfile"
      }
      driver = "raw_exec"
      config {
        command = "/bin/bash"
        args = ["-c", "cd local && docker build -t registry.service.consul:5000/fluentd . && docker push registry.service.consul:5000/fluentd"]
      }
      resources {
        cpu    = 100 # Mhz
        memory = 100  # MB
        network {
          mbits = 10
          port "up" {}
        }
      }
    }
  }
}
