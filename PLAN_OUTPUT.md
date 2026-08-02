
Warning: Deprecated Parameter

The parameter "dynamodb_table" is deprecated. Use parameter "use_lockfile" instead.
Acquiring state lock. This may take a few moments...

Terraform used the selected providers to generate the following execution
plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # module.identity.aws_iam_policy.audit_read_only will be created
  + resource "aws_iam_policy" "audit_read_only" {
      + arn              = (known after apply)
      + attachment_count = (known after apply)
      + description      = "Permite consultar recursos para tareas de auditor├¡a"
      + id               = (known after apply)
      + name             = "dev-audit-read-only-policy"
      + name_prefix      = (known after apply)
      + path             = "/"
      + policy           = jsonencode(
            {
              + Statement = [
                  + {
                      + Action   = [
                          + "ec2:Describe*",
                          + "s3:Get*",
                          + "s3:List*",
                          + "iam:Get*",
                          + "iam:List*",
                        ]
                      + Effect   = "Allow"
                      + Resource = "*"
                    },
                ]
              + Version   = "2012-10-17"
            }
        )
      + policy_id        = (known after apply)
      + tags_all         = (known after apply)
    }

  # module.identity.aws_iam_policy.data_processing_s3 will be created
  + resource "aws_iam_policy" "data_processing_s3" {
      + arn              = (known after apply)
      + attachment_count = (known after apply)
      + description      = "Permite acceso limitado al prefijo configurado en S3"
      + id               = (known after apply)
      + name             = "dev-data-processing-s3-policy"
      + name_prefix      = (known after apply)
      + path             = "/"
      + policy           = jsonencode(
            {
              + Statement = [
                  + {
                      + Action    = [
                          + "s3:ListBucket",
                        ]
                      + Condition = {
                          + StringLike = {
                              + "s3:prefix" = [
                                  + "raw/*",
                                ]
                            }
                        }
                      + Effect    = "Allow"
                      + Resource  = "arn:aws:s3:::realtime-data-platform-dev-raw"
                    },
                  + {
                      + Action   = [
                          + "s3:GetObject",
                          + "s3:PutObject",
                        ]
                      + Effect   = "Allow"
                      + Resource = "arn:aws:s3:::realtime-data-platform-dev-raw/raw/*"
                    },
                ]
              + Version   = "2012-10-17"
            }
        )
      + policy_id        = (known after apply)
      + tags_all         = (known after apply)
    }

  # module.identity.aws_iam_role.audit_read_only will be created
  + resource "aws_iam_role" "audit_read_only" {
      + arn                   = (known after apply)
      + assume_role_policy    = jsonencode(
            {
              + Statement = [
                  + {
                      + Action    = "sts:AssumeRole"
                      + Effect    = "Allow"
                      + Principal = {
                          + Service = "lambda.amazonaws.com"
                        }
                    },
                ]
              + Version   = "2012-10-17"
            }
        )
      + create_date           = (known after apply)
      + force_detach_policies = false
      + id                    = (known after apply)
      + managed_policy_arns   = (known after apply)
      + max_session_duration  = 3600
      + name                  = "dev-audit-read-only-role"
      + name_prefix           = (known after apply)
      + path                  = "/"
      + tags                  = {
          + "Environment" = "dev"
          + "ManagedBy"   = "Terraform"
        }
      + tags_all              = {
          + "Environment" = "dev"
          + "ManagedBy"   = "Terraform"
        }
      + unique_id             = (known after apply)

      + inline_policy (known after apply)
    }

  # module.identity.aws_iam_role.data_processing will be created
  + resource "aws_iam_role" "data_processing" {
      + arn                   = (known after apply)
      + assume_role_policy    = jsonencode(
            {
              + Statement = [
                  + {
                      + Action    = "sts:AssumeRole"
                      + Effect    = "Allow"
                      + Principal = {
                          + Service = [
                              + "lambda.amazonaws.com",
                              + "kinesisanalytics.amazonaws.com",
                            ]
                        }
                    },
                ]
              + Version   = "2012-10-17"
            }
        )
      + create_date           = (known after apply)
      + force_detach_policies = false
      + id                    = (known after apply)
      + managed_policy_arns   = (known after apply)
      + max_session_duration  = 3600
      + name                  = "dev-data-processing-role"
      + name_prefix           = (known after apply)
      + path                  = "/"
      + tags                  = {
          + "Environment" = "dev"
          + "ManagedBy"   = "Terraform"
        }
      + tags_all              = {
          + "Environment" = "dev"
          + "ManagedBy"   = "Terraform"
        }
      + unique_id             = (known after apply)

      + inline_policy (known after apply)
    }

  # module.identity.aws_iam_role_policy_attachment.audit_read_only will be created
  + resource "aws_iam_role_policy_attachment" "audit_read_only" {
      + id         = (known after apply)
      + policy_arn = (known after apply)
      + role       = "dev-audit-read-only-role"
    }

  # module.identity.aws_iam_role_policy_attachment.data_processing_s3 will be created
  + resource "aws_iam_role_policy_attachment" "data_processing_s3" {
      + id         = (known after apply)
      + policy_arn = (known after apply)
      + role       = "dev-data-processing-role"
    }

  # module.network.aws_route_table.private will be created
  + resource "aws_route_table" "private" {
      + arn              = (known after apply)
      + id               = (known after apply)
      + owner_id         = (known after apply)
      + propagating_vgws = (known after apply)
      + region           = "us-east-1"
      + route            = (known after apply)
      + tags             = {
          + "Environment" = "dev"
          + "ManagedBy"   = "Terraform"
          + "Name"        = "dev-private-route-table"
        }
      + tags_all         = {
          + "Environment" = "dev"
          + "ManagedBy"   = "Terraform"
          + "Name"        = "dev-private-route-table"
        }
      + vpc_id           = (known after apply)
    }

  # module.network.aws_route_table_association.private_a will be created
  + resource "aws_route_table_association" "private_a" {
      + id             = (known after apply)
      + region         = "us-east-1"
      + route_table_id = (known after apply)
      + subnet_id      = (known after apply)
    }

  # module.network.aws_route_table_association.private_b will be created
  + resource "aws_route_table_association" "private_b" {
      + id             = (known after apply)
      + region         = "us-east-1"
      + route_table_id = (known after apply)
      + subnet_id      = (known after apply)
    }

  # module.network.aws_subnet.private_a will be created
  + resource "aws_subnet" "private_a" {
      + arn                                            = (known after apply)
      + assign_ipv6_address_on_creation                = false
      + availability_zone                              = "us-east-1a"
      + availability_zone_id                           = (known after apply)
      + cidr_block                                     = "10.0.1.0/24"
      + enable_dns64                                   = false
      + enable_resource_name_dns_a_record_on_launch    = false
      + enable_resource_name_dns_aaaa_record_on_launch = false
      + id                                             = (known after apply)
      + ipv6_cidr_block                                = (known after apply)
      + ipv6_cidr_block_association_id                 = (known after apply)
      + ipv6_native                                    = false
      + map_public_ip_on_launch                        = false
      + owner_id                                       = (known after apply)
      + private_dns_hostname_type_on_launch            = (known after apply)
      + region                                         = "us-east-1"
      + tags                                           = {
          + "Environment" = "dev"
          + "ManagedBy"   = "Terraform"
          + "Name"        = "dev-private-subnet-a"
        }
      + tags_all                                       = {
          + "Environment" = "dev"
          + "ManagedBy"   = "Terraform"
          + "Name"        = "dev-private-subnet-a"
        }
      + vpc_id                                         = (known after apply)
    }

  # module.network.aws_subnet.private_b will be created
  + resource "aws_subnet" "private_b" {
      + arn                                            = (known after apply)
      + assign_ipv6_address_on_creation                = false
      + availability_zone                              = "us-east-1b"
      + availability_zone_id                           = (known after apply)
      + cidr_block                                     = "10.0.2.0/24"
      + enable_dns64                                   = false
      + enable_resource_name_dns_a_record_on_launch    = false
      + enable_resource_name_dns_aaaa_record_on_launch = false
      + id                                             = (known after apply)
      + ipv6_cidr_block                                = (known after apply)
      + ipv6_cidr_block_association_id                 = (known after apply)
      + ipv6_native                                    = false
      + map_public_ip_on_launch                        = false
      + owner_id                                       = (known after apply)
      + private_dns_hostname_type_on_launch            = (known after apply)
      + region                                         = "us-east-1"
      + tags                                           = {
          + "Environment" = "dev"
          + "ManagedBy"   = "Terraform"
          + "Name"        = "dev-private-subnet-b"
        }
      + tags_all                                       = {
          + "Environment" = "dev"
          + "ManagedBy"   = "Terraform"
          + "Name"        = "dev-private-subnet-b"
        }
      + vpc_id                                         = (known after apply)
    }

  # module.network.aws_vpc.main will be created
  + resource "aws_vpc" "main" {
      + arn                                  = (known after apply)
      + cidr_block                           = "10.0.0.0/16"
      + default_network_acl_id               = (known after apply)
      + default_route_table_id               = (known after apply)
      + default_security_group_id            = (known after apply)
      + dhcp_options_id                      = (known after apply)
      + enable_dns_hostnames                 = (known after apply)
      + enable_dns_support                   = true
      + enable_network_address_usage_metrics = (known after apply)
      + id                                   = (known after apply)
      + instance_tenancy                     = "default"
      + ipv6_association_id                  = (known after apply)
      + ipv6_cidr_block                      = (known after apply)
      + ipv6_cidr_block_network_border_group = (known after apply)
      + main_route_table_id                  = (known after apply)
      + owner_id                             = (known after apply)
      + region                               = "us-east-1"
      + tags                                 = {
          + "Environment" = "dev"
          + "ManagedBy"   = "Terraform"
          + "Name"        = "dev-data-vpc"
        }
      + tags_all                             = {
          + "Environment" = "dev"
          + "ManagedBy"   = "Terraform"
          + "Name"        = "dev-data-vpc"
        }
    }

  # module.network.aws_vpc_endpoint.s3 will be created
  + resource "aws_vpc_endpoint" "s3" {
      + arn                   = (known after apply)
      + cidr_blocks           = (known after apply)
      + dns_entry             = (known after apply)
      + id                    = (known after apply)
      + ip_address_type       = (known after apply)
      + network_interface_ids = (known after apply)
      + owner_id              = (known after apply)
      + policy                = (known after apply)
      + prefix_list_id        = (known after apply)
      + private_dns_enabled   = (known after apply)
      + region                = "us-east-1"
      + requester_managed     = (known after apply)
      + route_table_ids       = (known after apply)
      + security_group_ids    = (known after apply)
      + service_name          = "com.amazonaws.us-east-1.s3"
      + service_region        = (known after apply)
      + state                 = (known after apply)
      + subnet_ids            = (known after apply)
      + tags                  = {
          + "Environment" = "dev"
          + "ManagedBy"   = "Terraform"
          + "Name"        = "dev-s3-endpoint"
        }
      + tags_all              = {
          + "Environment" = "dev"
          + "ManagedBy"   = "Terraform"
          + "Name"        = "dev-s3-endpoint"
        }
      + vpc_endpoint_type     = "Gateway"
      + vpc_id                = (known after apply)

      + dns_options (known after apply)

      + subnet_configuration (known after apply)
    }

Plan: 13 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + audit_read_only_role_arn = (known after apply)
  + data_processing_role_arn = (known after apply)
  + private_subnet_ids       = [
      + (known after apply),
      + (known after apply),
    ]
  + vpc_id                   = (known after apply)


Note: You didn't use the -out option to save this plan, so Terraform can't
guarantee to take exactly these actions if you run "terraform apply" now.
