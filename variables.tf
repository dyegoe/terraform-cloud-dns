variable "name" {
  type        = string
  description = "The FQDN for the zone"
}

variable "cloud_providers" {
  type        = list(string)
  default     = ["aws"]
  description = "A list of the cloud providers to create the zone in. Values: aws, cloudflare"
}

variable "ttl_default" {
  type        = number
  default     = 300
  description = "The TTL default for all records"
}

variable "a_root" {
  type        = string
  description = "The IP address for the root A record"
}

variable "mx_providers" {
  type        = list(string)
  default     = []
  description = "A list of MX providers. Values: google, skymail"
}

variable "spf_providers" {
  type        = list(string)
  default     = []
  description = "A list of SPF providers. Values: google, mcsv, skymail, sendgrid"
}

variable "records" {
  default     = []
  description = "A list of objects with the following keys: name, type, value"
}
