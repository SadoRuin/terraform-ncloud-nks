variable "name" {
  description = "NKS Cluster 이름"
  type        = string
}

variable "k8s_version" {
  description = "NKS Cluster Kubernetes 버전 (Upgrade만 가능)"
  type        = string
  default     = null
}

variable "kube_network_plugin" {
  description = "NKS CNI 플러그인 (cilium 만 존재)"
  type        = string
  default     = "cilium"
}

variable "vpc_id" {
  description = "NKS Cluster를 생성할 VPC ID"
  type        = string
}

variable "zone" {
  description = "NKS Cluster를 생성할 가용 Zone"
  type        = string
}

variable "is_public_network" {
  description = "NKS Cluster Public Network 사용 여부"
  type        = bool
  default     = false
}

variable "subnet_id_list" {
  description = <<EOF
  NKS Cluster에서 사용할 Subnet ID 리스트
  - IP 대역(10.0.0.0/8,172.16.0.0/12,192.168.0.0/16) 내에서 /17~/26 범위의 Subnet 선택
  - Docker Bridge 대역의 충돌을 방지하기 위해 172.17.0.0/16 범위 내의 Subnet은 선택 불가
  EOF
  type        = list(string)
}

variable "lb_private_subnet_id" {
  description = <<EOF
  NKS Cluster에서 사용할 Private LB Subnet ID
  - IP 대역(10.0.0.0/8,172.16.0.0/12,192.168.0.0/16) 내에서 /17~/26 범위의 LB Subnet 선택
  - Docker Bridge 대역의 충돌을 방지하기 위해 172.17.0.0/16 범위 내의 LB Subnet은 선택 불가
  EOF
  type        = string
}

variable "lb_public_subnet_id" {
  description = "NKS Cluster에서 사용할 Public LB Subnet ID (SGN, JPN 리전에서만 지원)"
  type        = string
  default     = null
}

variable "maximum_node_count" {
  description = "NKS Cluster 최대 노드 수 (10 | 50)"
  type        = number
  default     = 10
}

variable "audit_log" {
  description = "NKS Cluster 로그 수집 여부"
  type        = bool
  default     = false
}

variable "login_key_name" {
  description = "NKS Cluster 인증키 이름"
  type        = string
}


variable "ip_acl_default_action" {
  description = "Control Plane에 대한 IP ACL 기본 액션 (allow | deny)"
  type        = string
  default     = "allow"
}

variable "ip_acl" {
  description = <<EOF
  Control Plane에 대한 IP ACL 리스트
  - 공인 IP주소를 기반으로 K8S Control Plane에 대한 액세스를 제한
  - CIDR block이 좁을수록 높은 우선 순위
  EOF
  type = list(object({
    action  = string           # 액션 (allow | deny)
    address = string           # 접근 소스 CIDR
    comment = optional(string) # 메모
  }))
  default = []
}

variable "oidc" {
  description = <<EOF
  OpenID Connect 설정
  - 하나의 OpenID를 이용하여 OpenID 인증을 허용하는 여러 플랫폼에서 사용자 인증을 손쉽게 구현
  - OIDC 제공자를 설정하여 K8S Service 클러스터에 OIDC 인증 기능 추가
  EOF
  type = object({
    issuer_url      = string           # OIDC 제공자 URL
    client_id       = string           # OIDC 클라이언트 ID
    username_claim  = optional(string) # 사용자의 username으로 사용할 claim
    groups_claim    = optional(string) # 사용자의 groups로 사용할 claim
    username_prefix = optional(string) # 기존 username(예: system:users)과의 충돌을 방지하기 위해 Username claim앞에 접두사가 추가
    groups_prefix   = optional(string) # 기존 groups(예: system:group)과의 충돌을 방지하기 위해 Groups claim 앞에 접두사가 추가
    required_claim  = optional(string) #  ID 토큰에 필수 claim을 지정하는 key=value 쌍. ','로 구분하여 여러 claim을 지정
  })
  default = null
}

variable "node_pools" {
  description = "NKS Cluster Node Pool 리스트"
  type = list(object({
    node_pool_name     = string                    # Node Pool 이름
    k8s_version        = optional(string)          # Node Pool Kubernetes 버전 (Upgrade만 가능)
    node_count         = number                    # Node Pool 노드 수
    ubuntu_version     = optional(string, "20.04") # Node Pool Ubuntu 버전 (16.04 | 18.04 | 20.04)
    product_generation = optional(string, "G2")    # Node 서버 세대 (G1 | G2)
    product_type       = string                    # Node 서버 타입 (High CPU | Standard | High Memory | CPU Intensive | GPU)
    product_name       = string                    # Node 서버 스펙 이름
    subnet_id_list     = list(string)              # Node Pool에서 사용할 Subnet ID 리스트
    autoscale = optional(object({                  # Node Pool Auto Scaling 설정
      enabled = bool                               # Auto Scaling 사용 여부
      max     = number                             # Auto Scaling 최대 노드 수
      min     = number                             # Auto Scaling 최소 노드 수
    }), null)
  }))
  default = []
}
