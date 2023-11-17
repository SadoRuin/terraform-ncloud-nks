# NCP NKS Terraform module

네이버 클라우드 플랫폼의 NKS 모듈입니다.

## Table of Contents

## [Usage](#table-of-contents)

```hcl

```

## [Resources](#table-of-contents)

### [Server](#table-of-contents)

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

### [IP ACL Inputs](#table-of-contents)

<!-- prettier-ignore -->
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|

### [OIDC Inputs](#table-of-contents)

<!-- prettier-ignore -->
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|

### [Node Pool Inputs](#table-of-contents)

<!-- prettier-ignore -->
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|

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
