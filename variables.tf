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

variable "dnssec" {
  type        = bool
  default     = false
  description = "Enable DNSSEC for the zone"
}

variable "aws_kms_users_arn" {
  type        = list(string)
  default     = []
  description = "A list of ARNs of IAM users that are allowed full manage the KMS key for DNSSEC"
}

variable "a_root_type" {
  type        = string
  default     = "A"
  description = "The type of the root A record. Values: A, ALIAS"
  validation {
    condition     = contains(["A", "ALIAS"], var.a_root_type)
    error_message = "The value of a_root_type must be A or ALIAS."
  }
}

variable "a_root" {
  type        = string
  default     = ""
  description = "The IP address for the root A record (if a_root_type is A) or the alias target (if a_root_type is ALIAS)"
}

variable "a_root_zone_id" {
  type        = string
  default     = ""
  description = "The zone ID for the root A record (if a_root_type is ALIAS)"
}

variable "cname_www_root" {
  type        = bool
  default     = true
  description = "Whether to create a CNAME record for www to root"
}

variable "cname_mail_skymail" {
  type        = bool
  default     = false
  description = "Whether to create CNAME records for mail related to skymail"
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
  description = "A list of objects with the following keys: name, type, ttl, priority, value"
}
