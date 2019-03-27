# IBM Cloud PaaS API Key:
variable ibm_bx_api_key {}

# IBM Cloud IaaS User (aka SoftLayer Username)
variable ibm_sl_username {}

# IBM Cloud IaaS User API key (aka SoftLayer User Api Key)
variable ibm_sl_api_key {}

variable APP_TOKEN {}

variable USER_KEY {}

variable datacenter {
  type = "map"

  default = {
    us-east1  = "wdc04"
    us-east2  = "wdc06"
    us-east3  = "wdc07"
    us-south1 = "dal10"
    us-south2 = "dal12"
    us-south3 = "dal13"
  }
}

variable node_count {
  type = "map"

  default = {
    haproxy = "2"
    web     = "4"
  }
}

# The target operating system for the web nodes
variable os {
  type = "map"

  default = {
    u16   = "UBUNTU_16_64"
    u18   = "UBUNTU_18_64"
    win16 = "WIN_2016-STD_64"
  }
}

# The number of cores each web virtual guest will recieve
variable vm_flavor {
  type = "map"

  default = {
    micro  = "B1_1X2X100"
    small  = "B1_2X4X100"
    medium = "B1_8X16X100"
    large  = "B1_16X32X100"
  }
}

variable priv_vlan {
  type = "map"

  default = {
    us-east1  = "2162809"
    us-east2  = "1669323"
    us-east3  = "2463707"
    us-south1 = "1286783"
    us-south2 = "1535681"
    us-south3 = "1583617"
  }
}

variable pub_vlan {
  type = "map"

  default = {
    us-east1  = "2162807"
    us-east2  = "2508931"
    us-east3  = "2463705"
    us-south1 = "1286781"
    us-south2 = "1535671"
    us-south3 = "1583615"
  }
}

variable domainname {
  default = "cloudintrsvc.com"
}
