################################################################################
# NKS Cluster
################################################################################

locals {
  cluster_type = (
    var.maximum_node_count == 10
    ? "SVR.VNKS.STAND.C002.M008.NET.SSD.B050.G002" # 10 nodes
    : (
      var.maximum_node_count == 50
      ? "SVR.VNKS.STAND.C004.M016.NET.SSD.B050.G002" # 50 nodes
      : null                                         # 잘못 입력하면 오류 발생
    )
  )
}

data "ncloud_nks_versions" "nks_version" {
  count = var.k8s_version != null ? 1 : 0

  filter {
    name   = "value"
    values = ["var.k8s_version"]
    regex  = true
  }
}

resource "ncloud_nks_cluster" "this" {
  name            = var.name
  hypervisor_code = var.hypervisor_code
  k8s_version = (
    var.k8s_version != null
    ? data.ncloud_nks_versions.nks_version[0].versions[0].value
    : null
  )
  kube_network_plugin  = var.kube_network_plugin
  vpc_no               = var.vpc_id
  zone                 = var.zone
  public_network       = var.is_public_network
  subnet_no_list       = var.subnet_id_list
  lb_private_subnet_no = var.lb_private_subnet_id
  lb_public_subnet_no  = var.lb_public_subnet_id
  cluster_type         = local.cluster_type

  login_key_name        = var.login_key_name
  ip_acl_default_action = var.ip_acl_default_action
  ip_acl                = var.ip_acl

  log {
    audit = var.audit_log
  }

  dynamic "oidc" {
    for_each = var.oidc != null ? toset([0]) : toset([])

    content {
      issuer_url      = var.oidc.issuer_url
      client_id       = var.oidc.client_id
      username_claim  = var.oidc.username_claim
      groups_claim    = var.oidc.groups_claim
      username_prefix = var.oidc.username_prefix
      groups_prefix   = var.oidc.groups_prefix
      required_claim  = var.oidc.required_claim
    }
  }
}


################################################################################
# NKS Cluster Node Pool
################################################################################

locals {
  node_pools = {
    for x in var.node_pools :
    x.node_pool_name => merge(
      x, {
        sw_ver = replace(x.ubuntu_version, ".", "")
      }
    )
  }
}

resource "ncloud_nks_node_pool" "this" {
  for_each = local.node_pools

  cluster_uuid   = ncloud_nks_cluster.this.id
  node_pool_name = each.value.node_pool_name
  k8s_version = (
    each.value.k8s_version != null
    ? "${each.value.k8s_version}-nks.1"
    : ncloud_nks_cluster.this.k8s_version
  )
  node_count     = each.value.node_count
  product_code   = data.ncloud_nks_server_products.server_product[each.key].products[0].value
  software_code  = data.ncloud_nks_server_images.server_image[each.key].images[0].value
  subnet_no_list = each.value.subnet_id_list
  autoscale {
    enabled = each.value.autoscale.enabled
    min     = each.value.autoscale.min
    max     = each.value.autoscale.max
  }
  dynamic "label" {
    for_each = each.value.labels != null ? each.value.labels : toset([])

    content {
      key   = label.value.key
      value = label.value.value
    }
  }

  dynamic "taint" {
    for_each = each.value.taints != null ? each.value.taints : toset([])

    content {
      key    = taint.value.key
      value  = taint.value.value
      effect = taint.value.effect
    }
  }
}



################################################################################
# Server Image
################################################################################

data "ncloud_nks_server_images" "server_image" {
  for_each = local.node_pools

  filter {
    name   = "label"
    values = ["ubuntu-${each.value.ubuntu_version}"]
    regex  = true
  }
}


################################################################################
# Server Product
################################################################################

locals {
  product_type = {
    "High CPU"      = "HICPU"
    "Standard"      = "STAND"
    "High Memory"   = "HIMEM"
    "CPU Intensive" = "CPU"
    "GPU"           = "GPU"
  }
}

data "ncloud_nks_server_products" "server_product" {
  for_each = local.node_pools

  software_code = data.ncloud_nks_server_images.server_image[each.key].images[0].value
  zone          = var.zone

  filter {
    name   = "product_type"
    values = [local.product_type[each.value.product_type]]
  }
  filter {
    name   = "label"
    values = [each.value.product_name]
  }
}
