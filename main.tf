# Сеть
resource "yandex_vpc_network" "network" {
  name = "devops-network"
}

resource "yandex_vpc_subnet" "subnet" {
  name           = "devops-subnet"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network.id
  v4_cidr_blocks = ["10.0.1.0/24"]
}

# VM1
resource "yandex_compute_instance" "vm1" {
  name = "vm1"
  zone = "ru-central1-a"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd8vmcue7aajpmeo39kk" # Ubuntu 22.04
      size     = 20
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}

# VM2
resource "yandex_compute_instance" "vm2" {
  name = "vm2"
  zone = "ru-central1-a"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd8vmcue7aajpmeo39kk" # Ubuntu 22.04
      size     = 20
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}

# Балансировщик
resource "yandex_alb_target_group" "tg" {
  name = "devops-tg"

  target {
    subnet_id  = yandex_vpc_subnet.subnet.id
    ip_address = yandex_compute_instance.vm1.network_interface[0].ip_address
  }

  target {
    subnet_id  = yandex_vpc_subnet.subnet.id
    ip_address = yandex_compute_instance.vm2.network_interface[0].ip_address
  }
}

resource "yandex_alb_backend_group" "bg" {
  name = "devops-bg"

  http_backend {
    name             = "backend"
    weight           = 1
    port             = 80
    target_group_ids = [yandex_alb_target_group.tg.id]

    healthcheck {
      timeout  = "10s"
      interval = "2s"
      http_healthcheck {
        path = "/"
      }
    }
  }
}

resource "yandex_alb_http_router" "router" {
  name = "devops-router"
}

resource "yandex_alb_virtual_host" "vh" {
  name           = "devops-vh"
  http_router_id = yandex_alb_http_router.router.id

  route {
    name = "route"
    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.bg.id
      }
    }
  }
}

resource "yandex_alb_load_balancer" "lb" {
  name = "devops-lb"

  network_id = yandex_vpc_network.network.id

  allocation_policy {
    location {
      zone_id   = "ru-central1-a"
      subnet_id = yandex_vpc_subnet.subnet.id
    }
  }

  listener {
    name = "listener"
    endpoint {
      address {
        external_ipv4_address {}
      }
      ports = [80]
    }
    http {
      handler {
        http_router_id = yandex_alb_http_router.router.id
      }
    }
  }
}
