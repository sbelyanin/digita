job "gl-token" {
  datacenters = ["dc1"]
  type = "batch"
  group "gl-token" {
    count = 1
    restart {
      attempts = 5
      interval = "10m"
      delay = "30s"
      mode = "delay"
    }

    task "gl-token" {
      driver = "raw_exec"
      config {
        command = "/bin/bash"
        args = ["/usr/local/bin/gl_cred2consul.sh"]
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

