variable "humanitec_organization" { default = "HUMANITEC_ORGANIZATION" }
variable "humanitec_token" { default = "HUMANITEC_TOKEN" }
variable "region" { default = "ca-central-1" }
variable "access_key" { default = "AWS_ACCESS_KEY" }
variable "secret_key" { default = "AWS_SECRET_KEY" }
variable "cluster_oidc" { default = "CLUSTER_OIDC" }

variable "app_id" { default = "myeksapp" }

terraform {
  required_providers {
    humanitec = {
      source = "humanitec/humanitec"
    }
  }
}

provider "humanitec" {
  org_id = var.humanitec_organization
  token  = var.humanitec_token
}

resource "humanitec_resource_definition" "aws_terraform_resource_ssm_parameter" {
  driver_type = "${var.humanitec_organization}/terraform"
  id          = "aws-terrafom-eks-ssm-parameter"
  name        = "aws-terrafom-eks-ssm-parameter"
  type        = "workload"

  criteria = [
    {
      res_id = "aws-terrafom-eks-ssm-parameter"
    }
  ]

  driver_inputs = {
    secrets = {
      variables = jsonencode({
        access_key = var.access_key
        secret_key = var.secret_key
      })
    },
    values = {
      "source" = jsonencode(
        {
          path = "iam-role-eks/terraform/parameter/"
          rev  = "refs/heads/main"
          url  = "https://github.com/nickhumanitec/humanitec-aws-examples.git"
        }
      )
      "variables" = jsonencode(
        {
          region          = var.region,
          parameter_name  = "/humanitec/test-$${context.app.id}-$${context.env.id}"
          parameter_value = "$${context.app.id}-$${context.env.id}"
        }
      )
    }
  }

}

resource "humanitec_resource_definition" "aws_terraform_resource_ssm_policy" {
  driver_type = "${var.humanitec_organization}/terraform"
  id          = "aws-terrafom-eks-ssm-policy"
  name        = "aws-terrafom-eks-ssm-policy"
  type        = "workload"

  criteria = [
    {
      res_id = "aws-terrafom-eks-ssm-policy"
    }
  ]

  driver_inputs = {
    secrets = {
      variables = jsonencode({
        access_key = var.access_key
        secret_key = var.secret_key
      })
    },
    values = {
      "source" = jsonencode(
        {
          path = "iam-role-eks/terraform/policy/"
          rev  = "refs/heads/main"
          url  = "https://github.com/nickhumanitec/humanitec-aws-examples.git"
        }
      )
      "variables" = jsonencode(
        {
          region        = var.region
          parameter_arn = "$${resources.workload#aws-terrafom-eks-ssm-parameter.outputs.parameter_arn}"
        }
      )
    }
  }

}

resource "humanitec_resource_definition" "aws_terraform_resource_role" {

  driver_type = "${var.humanitec_organization}/terraform"
  id          = "aws-terrafom-eks-role"
  name        = "aws-terrafom-eks-role"
  type        = "workload"

  criteria = [
    {
      res_id = "aws-terrafom-eks-role"
    }
  ]

  driver_inputs = {
    secrets = {
      variables = jsonencode({
        access_key = var.access_key
        secret_key = var.secret_key
      })
    },
    values = {
      "source" = jsonencode(
        {
          path = "iam-role-eks/terraform/role/"
          rev  = "refs/heads/main"
          url  = "https://github.com/nickhumanitec/humanitec-aws-examples.git"
        }
      )
      "variables" = jsonencode(
        {
          policies        = ["$${resources.workload#aws-terrafom-eks-ssm-policy.outputs.policy_ssm_arn}"]
          cluster_oidc    = var.cluster_oidc
          namespace       = "$${context.app.id}-$${context.env.id}"
          service_account = "$${context.app.id}-$${context.env.id}-backend"
          region          = var.region
        }
      )
    }
  }

}

resource "humanitec_resource_definition" "aws_eks_namespace" {
  id   = "aws-eks-namespace"
  name = "aws-eks-namespace"
  type = "k8s-namespace"

  criteria = [
    {
      app_id   = var.app_id
      env_id   = null
      env_type = null
      res_id   = "k8s-namespace"
    }
  ]

  driver_type = "humanitec/template"

  driver_inputs = {
    secrets = {
      templates = jsonencode({
        # outputs = ""
      })
    },
    values = {
      templates = jsonencode({
        # cookie    = ""
        init      = ""
        manifests = <<EOL
namespace:
  location: cluster
  data:
    apiVersion: v1
    kind: Namespace
    metadata:
      name: $${context.app.id}-$${context.env.id}
EOL
        outputs   = <<EOL
namespace: $${context.app.id}-$${context.env.id}
EOL
      })
    }
  }

}

resource "humanitec_resource_definition" "aws_eks_injector" {
  count = 1
  id    = "aws-eks-injector"
  name  = "aws-eks-injector"
  type  = "workload"

  criteria = [
    {
      app_id   = var.app_id
      env_id   = null
      env_type = null
      res_id   = "modules.backend"
    }
  ]

  driver_type = "humanitec/template"
  driver_inputs = {
    secrets = {
      templates = jsonencode({
        # outputs = ""
      })
    },
    values = {
      templates = jsonencode({
        # cookie    = ""
        init      = ""
        manifests = <<EOL
serviceaccount.yaml:
  data:
    apiVersion: v1
    kind: ServiceAccount
    metadata:
      name: $${context.app.id}-$${context.env.id}-backend
      annotations:
        eks.amazonaws.com/role-arn: $${resources.workload#aws-terrafom-eks-role.outputs.role_arn}
        parameter: $${resources.workload#aws-terrafom-eks-ssm-parameter.outputs.parameter_arn}
        policy: $${resources.workload#aws-terrafom-eks-ssm-policy.outputs.policy_ssm_arn}
        context: {{trimPrefix "modules." "$${context.res.id}"}}
        fullContext: $${context.res.id}
        app: $${context.app.id}
        env: $${context.env.id}
  location: namespace
EOL
        outputs   = <<EOL
update:
  - op: add
    path: /spec/serviceAccountName
    value: $${context.app.id}-$${context.env.id}-backend
  - op: add
    path: /spec/containers/aws-cli/variables/AWS_PARAMETER
    value: $${resources.workload#aws-terrafom-eks-ssm-parameter.outputs.parameter_arn}
EOL
      })
    }
  }
}
