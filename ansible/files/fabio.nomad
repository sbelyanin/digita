job "fabio" {  
  datacenters = ["dc1"]

  type = "system"

  update {
    stagger = "5s"
    max_parallel = 1
  }

  group "fabio" {
    task "fabio" {
      driver = "raw_exec"

      config {
        command = "fabio-1.5.11-go1.11.5-linux_amd64"
      }

      artifact {
        source = "https://github.com/fabiolb/fabio/releases/download/v1.5.11/fabio-1.5.11-go1.11.5-linux_amd64"

      }

      resources {
        cpu = 20
        memory = 64
        network {
          mbits = 1

          port "lb" {
            static = 9998
          }
          port "ui" {
            static = 9999
          }
        }
      }
    }
  }
}


