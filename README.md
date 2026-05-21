# instance-type-availability

A utility module that queries AWS for the availability zones (AZs) in the
current region where one or more EC2 instance types can be launched.

Use it as a guard-rail before creating subnets or Auto Scaling Groups so that
you never land in an AZ that silently rejects your chosen instance type.

---

## Usage

```hcl
module "az_check" {
  source = "git::https://github.com/your-org/terraform-modules.git//instance-type-availability?ref=v1.0.0"

  instance_types = ["t3.micro", "t3.small"]
}

# Use the safe AZ list directly in subnet resources
resource "aws_subnet" "app" {
  for_each          = toset(module.az_check.azs_supporting_all_types)
  vpc_id            = aws_vpc.main.id
  availability_zone = each.key
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, index(module.az_check.azs_supporting_all_types, each.key))
}
```

---

## Requirements

| Name      | Version   |
|-----------|-----------|
| terraform | >= 1.3.0  |
| aws       | >= 5.0.0  |

---

## Inputs

| Name            | Description                                              | Type           | Default                    | Required |
|-----------------|----------------------------------------------------------|----------------|----------------------------|----------|
| `instance_types`| List of EC2 instance types to check.                    | `list(string)` | `["t3.micro"]`             | no       |
| `opt_in_status` | AZ opt-in filter (see AWS docs).                        | `list(string)` | `["opt-in-not-required"]`  | no       |

---

## Outputs

| Name                      | Description                                                          |
|---------------------------|----------------------------------------------------------------------|
| `region`                  | Current AWS region name.                                             |
| `all_azs`                 | All AZs in the region before instance-type filtering.                |
| `az_to_supported_types`   | Map of AZ → supported types from the requested set.                  |
| `type_to_supported_azs`   | Inverse map: instance type → AZs where it is available.              |
| `azs_supporting_all_types`| AZs that support **every** requested instance type. Use for subnets. |
| `supported_azs`           | Flat list of AZs supporting at least one requested type.             |

---

## Why `azs_supporting_all_types` instead of `supported_azs`

When you request multiple instance types, an AZ might support `t3.micro` but
not `c5.xlarge`. If your workload needs both, use `azs_supporting_all_types`
so every subnet you create can launch any node in your fleet. `supported_azs`
is a convenience output for the common single-type case.

---

## Testing

```bash
cd tests
go test -v -timeout 10m
```

Tests require valid AWS credentials and will create/destroy real resources.
