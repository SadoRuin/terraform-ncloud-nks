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

resource "ncloud_nks_cluster" "this" {
  name                 = var.name
  k8s_version          = var.k8s_version != null ? "${var.k8s_version}-nks.1" : null
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

  dynamic "log" {
    for_each = var.audit_log ? toset([0]) : toset([])

    content {
      audit = var.audit_log
    }
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
  k8s_version    = each.value.k8s_version != null ? "${each.value.k8s_version}-nks.1" : null
  node_count     = each.value.node_count
  product_code   = data.ncloud_server_product.server_product[each.key].id
  software_code  = "SW.VSVR.OS.LNX64.UBNTU.SVR${each.value.sw_ver}.WRKND.B050"
  subnet_no_list = each.value.subnet_id_list

  dynamic "autoscale" {
    for_each = (
      each.value.autoscale != null
      ? toset(values(each.value.autoscale))
      : toset([])
    )

    content {
      enabled = autoscale.value.enabled
      max     = autoscale.value.max
      min     = autoscale.value.min
    }
  }
}


################################################################################
# Server Image
################################################################################

data "ncloud_server_image" "server_image" {
  for_each = local.node_pools

  filter {
    name   = "product_name"
    values = ["ubuntu-${each.value.ubuntu_version}"]
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

data "ncloud_server_product" "server_product" {
  for_each = local.node_pools

  server_image_product_code = data.ncloud_server_image.server_image[each.key].id

  filter {
    name   = "generation_code"
    values = [upper(each.value.product_generation)]
  }
  filter {
    name   = "product_type"
    values = [local.product_type[each.value.product_type]]
  }
  filter {
    name   = "product_name"
    values = [each.value.product_name]
  }
}
