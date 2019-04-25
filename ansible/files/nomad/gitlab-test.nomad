job "gl-test" {
  datacenters = ["dc1"]
  type = "batch"
  group "gl-test" {
    count = 1
    restart {
      attempts = 5
      interval = "10m"
      delay = "30s"
      mode = "delay"
    }

    task "gl-test" {
      driver = "raw_exec"
      config {
        command = "/bin/bash"
        args = ["-c", "consul kv put gitlab/nomad_node_id ${node.unique.id}"]
      }
      resources {
        cpu    = 100 # Mhz
        memory = 100  # MB
        network {
          mbits = 10
          port "uptime" {}
        }
      }
    }
  }
}

