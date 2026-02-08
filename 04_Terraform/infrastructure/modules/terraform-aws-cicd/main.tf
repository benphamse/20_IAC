# S3 Bucket for CodePipeline Artifacts
resource "aws_s3_bucket" "artifacts" {
  bucket        = "${var.naming_prefix}-cicd-artifacts"
  force_destroy = var.force_destroy_artifacts

  tags = merge(var.tags, {
    Name = "${var.naming_prefix}-cicd-artifacts"
  })
}

# S3 Bucket Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# S3 Bucket Public Access Block
resource "aws_s3_bucket_public_access_block" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# CodeCommit Repository
resource "aws_codecommit_repository" "main" {
  count = var.create_codecommit_repo ? 1 : 0

  repository_name = "${var.naming_prefix}-repo"
  description     = "Source code repository for ${var.naming_prefix}"

  tags = merge(var.tags, {
    Name = "${var.naming_prefix}-codecommit-repo"
  })
}

# CodeBuild Project
resource "aws_codebuild_project" "main" {
  name         = "${var.naming_prefix}-build"
  description  = "Build project for ${var.naming_prefix}"
  service_role = var.codebuild_service_role_arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = var.build_compute_type
    image                       = var.build_image
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = var.privileged_mode

    dynamic "environment_variable" {
      for_each = var.environment_variables
      content {
        name  = environment_variable.value.name
        value = environment_variable.value.value
        type  = environment_variable.value.type
      }
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = var.buildspec_file != null ? var.buildspec_file : "buildspec.yml"
  }

  tags = merge(var.tags, {
    Name = "${var.naming_prefix}-codebuild-project"
  })
}

# CodeDeploy Application
resource "aws_codedeploy_application" "main" {
  count = var.enable_codedeploy ? 1 : 0

  name             = "${var.naming_prefix}-deploy-app"
  compute_platform = var.compute_platform

  tags = merge(var.tags, {
    Name = "${var.naming_prefix}-codedeploy-app"
  })
}

# CodeDeploy Deployment Group
resource "aws_codedeploy_deployment_group" "main" {
  count = var.enable_codedeploy ? 1 : 0

  app_name              = aws_codedeploy_application.main[0].name
  deployment_group_name = "${var.naming_prefix}-deploy-group"
  service_role_arn      = var.codedeploy_service_role_arn

  deployment_config_name = var.deployment_config_name

  dynamic "ec2_tag_filter" {
    for_each = var.ec2_tag_filters
    content {
      key   = ec2_tag_filter.value.key
      type  = ec2_tag_filter.value.type
      value = ec2_tag_filter.value.value
    }
  }

  dynamic "ecs_service" {
    for_each = var.ecs_service_name != null ? [1] : []
    content {
      cluster_name = var.ecs_cluster_name
      service_name = var.ecs_service_name
    }
  }

  blue_green_deployment_config {
    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = var.blue_green_termination_wait_time
    }

    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }

    green_fleet_provisioning_option {
      action = "COPY_AUTO_SCALING_GROUP"
    }
  }

  tags = merge(var.tags, {
    Name = "${var.naming_prefix}-codedeploy-group"
  })
}

# CodePipeline
resource "aws_codepipeline" "main" {
  name     = "${var.naming_prefix}-pipeline"
  role_arn = var.codepipeline_service_role_arn

  artifact_store {
    location = aws_s3_bucket.artifacts.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = var.source_provider
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = var.source_provider == "CodeCommit" ? {
        RepositoryName = var.create_codecommit_repo ? aws_codecommit_repository.main[0].repository_name : var.existing_repo_name
        BranchName     = var.source_branch
        } : {
        Owner      = var.github_owner
        Repo       = var.github_repo
        Branch     = var.source_branch
        OAuthToken = var.github_token
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.main.name
      }
    }
  }

  dynamic "stage" {
    for_each = var.enable_codedeploy ? [1] : []
    content {
      name = "Deploy"

      action {
        name            = "Deploy"
        category        = "Deploy"
        owner           = "AWS"
        provider        = "CodeDeploy"
        input_artifacts = ["build_output"]
        version         = "1"

        configuration = {
          ApplicationName     = aws_codedeploy_application.main[0].name
          DeploymentGroupName = aws_codedeploy_deployment_group.main[0].deployment_group_name
        }
      }
    }
  }

  tags = merge(var.tags, {
    Name = "${var.naming_prefix}-codepipeline"
  })
}
