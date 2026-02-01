Reference AgentS Skill
<https://skills.sh/wshobson/agents/terraform-module-library>

IaC Concepts
Hashicorp Introduction
Terraform Basics
Terraform Provisioners
Terraform Providers
Terraform Language
Variables and Data
Meta Arguments
>> 1:54:40==Expressions
>> 2:41:01==Terraform State
>> 2:45:42==Initialization
>> 2:48:09==Writing and Modifying
>> 2:51:17==Plan and Apply
>> 2:54:23==Drift
>> 3:01:24==Troubleshooting
>> 3:05:55==Terraform Modules
>> 3:11:25==Terraform Workflows
>> 3:18:28==Terraform Backends
>> 3:37:22==Resources and Complex Types
>> 3:48:10==Built in Functions
>> 4:18:30==Terraform Cloud
>> 4:42:10==Terraform Enterprise
>> 4:51:47==Workspaces
>> 5:07:53==Sentinel and Terraform
>> 5:54:42==Packer
>> 6:22:04==Consul
>> 6:23:13==Vault
>> 6:56:06==Miscellaneous

```shell
export AWS_ACCESS_KEY_ID="your_key"
export AWS_SECRET_ACCESS_KEY="your_secret"
export AWS_DEFAULT_REGION=us-east-1

terrafrom init # This command initializes the Terraform working directory, downloading necessary providers and modules.
terraform state list # This command lists all resources in the current Terraform state.
terraform state show aws_instance.example  # Xem chi tiết instance
terrafrom validate # This command will check if your Terraform files are syntactically valid.
terrafrom plan -> # This command will show you the changes that will be applied to your infrastructure.
terrafrom apply
terrafrom destroy
terraform init -migrate-state

terraform apply -target=aws_instance.example # This command applies changes to the specified resource only.
terraform apply -var-file="envs/dev/terraform.tfvars"
terraform apply -var-file="envs/dev/terraform.tfvars" -auto-approve
terraform output

terraform fmt # This command formats your Terraform files to a canonical format and style.

```

Of course. This is a very common error when working with AWS RDS and Terraform.

### TL;DR: The Simple Explanation

The error message `Cannot find version 5.7.37 for mysql` is coming directly from the AWS API. It means that AWS RDS does
not offer (or no longer offers) the specific MySQL version `5.7.37` in the region you are trying to deploy to.

This usually happens for one of two reasons:

1. **Version Deprecation:** AWS regularly retires older minor versions of database engines. MySQL 5.7 has passed its
   end-of-life, and AWS has been removing older minor versions. `5.7.37` is likely one of them.
2. **Typo or Incorrect Version:** The version number might be a typo, or it's simply not a version that AWS ever
   supported.

---

### How to Fix It

You need to find a valid, available MySQL version in your target AWS region and update your Terraform code.

#### Step 1: Find an Available MySQL Version

You can find the available versions using either the AWS Command Line Interface (CLI) or the AWS Management Console. The
CLI is the quickest and most reliable method.

**Using the AWS CLI (Recommended)**

Open your terminal and run this command. It will list all available MySQL engine versions in your configured default
region.

```bash
# To list all available MySQL versions and sort them
aws rds describe-db-engine-versions --engine mysql --query "DBEngineVersions[].EngineVersion" --output text | sort -V

# To find the latest available version for the 5.7 family
aws rds describe-db-engine-versions --engine mysql --engine-version 5.7 --query "DBEngineVersions | sort_by(@, &EngineVersion) | [-1].EngineVersion"
```

You will get a list of versions. Look for a recent one in the `5.7.x` family, such as `5.7.44`, or consider upgrading to
a newer major version like `8.0.x`.

**Example Output:**

```
...
5.7.42
5.7.43
5.7.44
8.0.28
8.0.32
8.0.35
8.0.36
...
```

Based on this output, `5.7.44` would be a valid replacement.

#### Step 2: Update Your Terraform Code

The error message tells you exactly where the problem is:
`on ../modules/database/main.tf line 1, in resource "aws_db_instance" "database"`

1. Open the file `../modules/database/main.tf`.
2. Find the `aws_db_instance` resource.
3. Locate the `engine_version` attribute and change its value to an available version you found in Step 1.

**Example Code Change:**

Let's say your `main.tf` file looks like this:

```terraform
# ../modules/database/main.tf

resource "aws_db_instance" "database" {
  # ... other arguments ...
  identifier     = "three-tier-db"
  engine         = "mysql"
  engine_version = "5.7.37"  # <--- THIS IS THE PROBLEM LINE
  instance_class = "db.t3.micro"
  username       = "admin"
  password       = var.db_password
  # ... other arguments ...
}
```

You would change it to a valid version, for example `5.7.44`:

```terraform
# ../modules/database/main.tf

resource "aws_db_instance" "database" {
  # ... other arguments ...
  identifier     = "three-tier-db"
  engine         = "mysql"
  engine_version = "5.7.44"  # <--- THIS IS THE FIX
  instance_class = "db.t3.micro"
  username       = "admin"
  password       = var.db_password
  # ... other arguments ...
}
```

If the `engine_version` is set via a variable, you'll need to trace it back to where the variable is defined (e.g., in a
`terraform.tfvars` file or a root module) and change it there.

#### Step 3: Re-run Terraform

After saving the file, run `terraform apply` again. The plan should now show the correct version, and the apply should
succeed.

---

### Best Practices and Recommendations

1. **Upgrade to MySQL 8.0:** MySQL 5.7 reached its community End of Life (EOL) in October 2023. AWS will end standard
   support for it in February 2024. You should strongly consider upgrading to a supported major version like MySQL 8.0
   for security patches, bug fixes, and new features.

2. **Use a Data Source for Resilience:** To avoid this problem in the future, you can use the `aws_rds_engine_version`
   data source in Terraform to automatically find the latest available version within a specific family.

   ```terraform
   # Find the latest available version in the 5.7 family
   data "aws_rds_engine_version" "mysql" {
     engine  = "mysql"
     version = "5.7" # This will find the latest 5.7.x, not just "5.7"
   }
   
   # Or, preferably, find the latest 8.0 version
   data "aws_rds_engine_version" "mysql_latest" {
     engine  = "mysql"
     version = "8.0"
   }

   resource "aws_db_instance" "database" {
     # ... other arguments ...
     engine               = "mysql"
     engine_version       = data.aws_rds_engine_version.mysql_latest.version # Use the result from the data source
     # ...
   }
   ```

   This makes your configuration more robust, as it will automatically adapt if AWS retires the specific minor version
   you were using.
