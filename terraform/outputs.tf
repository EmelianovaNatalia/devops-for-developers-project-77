output "lb_public_ip" {
  value = yandex_alb_load_balancer.lb.listener[0].endpoint[0].address[0].external_ipv4_address[0].address
  description = "Public IP address of the load balancer"
}

output "vm1_public_ip" {
  value = yandex_compute_instance.vm1.network_interface[0].nat_ip_address
  description = "Public IP of vm1"
}

output "vm2_public_ip" {
  value = yandex_compute_instance.vm2.network_interface[0].nat_ip_address
  description = "Public IP of vm2"
}
