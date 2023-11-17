output "nks_cluster" {
  description = "NKS Cluster 출력"
  value       = ncloud_nks_node_pool.this
}

output "nks_node_pools" {
  description = "Node Pool 맵 출력"
  value       = ncloud_nks_node_pool.this
}
