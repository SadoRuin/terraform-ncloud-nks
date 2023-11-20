# NCP NKS Terraform module

네이버 클라우드 플랫폼의 NKS 모듈입니다.

## Table of Contents

## [Usage](#table-of-contents)

```hcl
module "nks" {
  source = "<THIS REPOSITORY URL>"

  name              = "test-cluster"
  k8s_version       = "1.24.10"
  vpc_id            = module.tf_test_vpc.vpc.id
  zone              = "KR-1"
  is_public_network = false
  subnet_id_list = [
    module.tf_test_vpc.subnets["tf-test-was-sbn"].id
  ]
  lb_private_subnet_id = module.tf_test_vpc.subnets["tf-test-nlb-sbn"].id
  maximum_node_count   = 10
  audit_log            = false
  login_key_name       = "<YOUR LOGINKEY>"

  node_pools = [
    {
      node_pool_name = "test-node-pool"
      # k8s_version    = "1.24.10"
      node_count     = 1
      ubuntu_version = "18.04"
      product_type   = "High CPU"
      product_name   = "vCPU 2EA, Memory 4GB, [SSD]Disk 50GB"
      subnet_id_list = [
        module.tf_test_vpc.subnets["tf-test-was-sbn"].id
      ]
    }
  ]
}
```

## [Resources](#table-of-contents)

### [NKS](#table-of-contents)

<!-- prettier-ignore -->
| Name | Type |
|------|------|
| [ncloud_nks_cluster.this](https://registry.terraform.io/providers/NaverCloudPlatform/ncloud/latest/docs/resources/nks_cluster) | resource |
| [ncloud_nks_node_pool.this](https://registry.terraform.io/providers/NaverCloudPlatform/ncloud/latest/docs/resources/nks_node_pool) | resource |
| [ncloud_server_image.server_image](https://registry.terraform.io/providers/NaverCloudPlatform/ncloud/latest/docs/data-sources/server_image) | data |
| [ncloud_server_product.server_product](https://registry.terraform.io/providers/NaverCloudPlatform/ncloud/latest/docs/data-sources/server_product) | data |

## [Inputs](#table-of-contents)

<!-- prettier-ignore -->
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | NKS Cluster 이름 | `string` | - | yes |
| k8s_version | NKS Cluster Kubernetes 버전 (Upgrade만 가능, 미입력시 최신버전 사용) | `string` | `null` | no |
| kube_network_plugin | NKS CNI 플러그인 (cilium 만 존재) | `string` | `"cilium"` | no |
| vpc_id | NKS Cluster를 생성할 VPC ID | `string` | - | yes |
| zone | NKS Cluster를 생성할 가용 Zone | `string` | - | yes |
| is_public_network | NKS Cluster Public Network 사용 여부 | `bool` | `false` | no |
| subnet_id_list | NKS Cluster에서 사용할 Subnet ID 리스트<br>- IP 대역(10.0.0.0/8,172.16.0.0/12,192.168.0.0/16) 내에서 /17~/26 범위의 Subnet 선택<br>- Docker Bridge 대역의 충돌을 방지하기 위해 172.17.0.0/16 범위 내의 Subnet은 선택 불가 | `list(string)` | - | yes |
| lb_private_subnet_id | NKS Cluster에서 사용할 Private LB Subnet ID<br>- IP 대역(10.0.0.0/8,172.16.0.0/12,192.168.0.0/16) 내에서 /17~/26 범위의 Subnet 선택<br>- Docker Bridge 대역의 충돌을 방지하기 위해 172.17.0.0/16 범위 내의 Subnet은 선택 불가 | `string` | - | yes |
| lb_public_subnet_id | NKS Cluster에서 사용할 Public LB Subnet ID (SGN, JPN 리전에서만 지원) | `string` | `null` | no |
| maximum_node_count | NKS Cluster 최대 노드 수 (10 \| 50) | `number` | `10` | no |
| audit_log | NKS Cluster 로그 수집 여부 | `bool` | `false` | no |
| login_key_name | NKS Cluster 인증키 이름 | `string` | - | yes |
| ip_acl_default_action | Control Plane에 대한 IP ACL 기본 액션 (allow \| deny) | `string` | `"allow"` | no |
| [ip_acl](#ip-acl-inputs) | Control Plane에 대한 IP ACL 리스트<br>- 공인 IP주소를 기반으로 K8S Control Plane에 대한 액세스를 제한<br>- CIDR block이 좁을수록 높은 우선 순위 | <pre>list(object({<br>  action  = string<br>  address = string<br>  comment = optional(string)<br>}))</pre> | `[]` | no |
| [oidc](#oidc-inputs) | OpenID Connect 설정<br>- 하나의 OpenID를 이용하여 OpenID 인증을 허용하는 여러 플랫폼에서 사용자 인증을 손쉽게 구현<br>- OIDC 제공자를 설정하여 K8S Service 클러스터에 OIDC 인증 기능 추가 | <pre>object({<br>  issuer_url      = string<br>  client_id       = string<br>  username_claim  = optional(string)<br>  groups_claim    = optional(string)<br>  username_prefix = optional(string)<br>  groups_prefix   = optional(string)<br>  required_claim  = optional(string)<br>})</pre> | `null` | no |
| [node_pools](#node-pool-inputs) | NKS Cluster Node Pool 리스트 | <pre>list(object({<br>  node_pool_name     = string<br>  k8s_version        = optional(string)<br>  node_count         = number<br>  ubuntu_version     = optional(string, "20.04")<br>  product_generation = optional(string, "G2")<br>  product_type       = string<br>  product_name       = string<br>  subnet_id_list     = list(string)<br>  autoscale = optional(object({<br>    enabled = bool<br>    min     = number<br>    max     = number<br>  }), { enabled = false, min = 0, max = 0 })<br>}))</pre> | `[]` | no |

### [IP ACL Inputs](#table-of-contents)

<!-- prettier-ignore -->
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| action | 액션 (allow \| deny) | `string` | - | yes |
| address | 접근 소스 CIDR | `string` | - | yes |
| comment | 메모 | `string` | - | no |

### [OIDC Inputs](#table-of-contents)

<!-- prettier-ignore -->
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| issuer_url | OIDC 제공자 URL | `string` | - | yes |
| client_id | OIDC 클라이언트 ID | `string` | - | yes |
| username_claim | 사용자의 username으로 사용할 claim | `string` | - | no |
| groups_claim | 사용자의 groups로 사용할 claim | `string` | - | no |
| username_prefix | 기존 username(예: system:users)과의 충돌을 방지하기 위해 Username claim앞에 접두사가 추가 | `string` | - | no |
| groups_prefix | 기존 groups(예: system:group)과의 충돌을 방지하기 위해 Groups claim 앞에 접두사가 추가 | `string` | - | no |
| required_claim | ID 토큰에 필수 claim을 지정하는 key=value 쌍. ','로 구분하여 여러 claim을 지정 | `string` | - | no |

### [Node Pool Inputs](#table-of-contents)

<!-- prettier-ignore -->
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| node_pool_name | Node Pool 이름 | `string` | - | yes |
| k8s_version | Node Pool Kubernetes 버전 (Upgrade만 가능, 미입력시 Cluster 버전 사용) | `string` | - | no |
| node_count | Node Pool 노드 수 | `number` | - | yes |
| ubuntu_version | Node Pool Ubuntu 버전 (16.04 \| 18.04 \| 20.04) | `string` | `"20.04"` | no |
| product_generation | Node 서버 세대 (G1 \| G2) | `string` | `"G2"` | no |
| product_type | Node 서버 타입 (High CPU \| Standard \| High Memory \| CPU Intensive \| GPU) | `string` | - | yes |
| product_name | Node 서버 스펙 이름 | `string` | - | yes |
| subnet_id_list | Node Pool에서 사용할 Subnet ID 리스트 | `list(string)` | - | yes |
| [autoscale](#autoscale_inputs) | Node Pool Auto Scaling 설정 | <pre>object({<br>  enabled = bool<br>  min     = number<br>  max     = number<br>})</pre> | <pre>{<br>  enabled = false<br>  min = 0<br>  max = 0<br>}</pre> | no |

- <a name="autoscale_inputs"></a> [**Autosacle Inputs**](#node-pool-inputs)

  <!-- prettier-ignore -->
  | Name | Description | Type | Default | Required |
  |------|-------------|------|---------|:--------:|
  | enabled | Auto Scaling 사용 여부 | `bool` | - | yes |
  | min | Auto Scaling 최소 노드 수 | `number` | - | yes |
  | max | Auto Scaling 최대 노드 수 | `number` | - | yes |

## [Outputs](#table-of-contents)

<!-- prettier-ignore -->
| Name | Description | Key값 (Map 형식) |
|------|-------------|-----------------|
| nks_cluster | NKS Cluster 리소스 출력 | - |
| nks_node_pools | NKS Node Pool 리소스들을 Map형식으로 출력 | `"Node Pool 이름"` |

## [Requirements](#table-of-contents)

<!-- prettier-ignore -->
| Name | Version |
|------|---------|
| [terraform](https://developer.hashicorp.com/terraform/install) | >= 1.0    |
| [ncloud](https://registry.terraform.io/providers/NaverCloudPlatform/ncloud/latest) | >= 2.3.18 |

## [Providers](#table-of-contents)

<!-- prettier-ignore -->
| Name | Version |
|------|---------|
| [ncloud](https://registry.terraform.io/providers/NaverCloudPlatform/ncloud/latest) | >= 2.3.18 |
