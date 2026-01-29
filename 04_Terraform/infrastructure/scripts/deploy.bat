@echo off
REM Terraform deployment script for Windows
REM Usage: deploy.bat <environment> <action>
REM Example: deploy.bat dev plan

setlocal EnableDelayedExpansion

set ENVIRONMENT=%1
set ACTION=%2
set SCRIPT_DIR=%~dp0
set PROJECT_ROOT=%SCRIPT_DIR%..\
set ENV_DIR=%PROJECT_ROOT%environments\%ENVIRONMENT%

REM Validate inputs
if "%ENVIRONMENT%"=="" (
    echo [ERROR] Usage: %0 ^<environment^> ^<action^>
    echo [INFO] Available environments: dev, staging, prod
    echo [INFO] Available actions: init, plan, apply, destroy, validate, fmt
    exit /b 1
)

if "%ACTION%"=="" (
    echo [ERROR] Usage: %0 ^<environment^> ^<action^>
    echo [INFO] Available environments: dev, staging, prod
    echo [INFO] Available actions: init, plan, apply, destroy, validate, fmt
    exit /b 1
)

REM Check if environment directory exists
if not exist "%ENV_DIR%" (
    echo [ERROR] Environment directory not found: %ENV_DIR%
    exit /b 1
)

REM Check if terraform.tfvars exists
if not exist "%ENV_DIR%\terraform.tfvars" (
    echo [ERROR] terraform.tfvars not found in %ENV_DIR%
    exit /b 1
)

echo [INFO] Working with environment: %ENVIRONMENT%
echo [INFO] Action: %ACTION%
echo [INFO] Directory: %ENV_DIR%

cd /d "%ENV_DIR%"

if "%ACTION%"=="init" (
    echo [INFO] Initializing Terraform...
    terraform init -upgrade
    echo [SUCCESS] Terraform initialized successfully
) else if "%ACTION%"=="validate" (
    echo [INFO] Validating Terraform configuration...
    terraform validate
    echo [SUCCESS] Terraform configuration is valid
) else if "%ACTION%"=="fmt" (
    echo [INFO] Formatting Terraform files...
    terraform fmt -recursive "%PROJECT_ROOT%"
    echo [SUCCESS] Terraform files formatted
) else if "%ACTION%"=="plan" (
    echo [INFO] Creating Terraform execution plan...
    terraform plan -var-file="terraform.tfvars" -out="tfplan"
    echo [SUCCESS] Terraform plan created successfully
) else if "%ACTION%"=="apply" (
    echo [WARNING] This will apply changes to %ENVIRONMENT% environment
    set /p CONFIRM="Are you sure you want to continue? (y/N): "
    if /i "!CONFIRM!"=="y" (
        echo [INFO] Applying Terraform changes...
        if exist "tfplan" (
            terraform apply "tfplan"
        ) else (
            terraform apply -var-file="terraform.tfvars" -auto-approve
        )
        echo [SUCCESS] Terraform changes applied successfully
    ) else (
        echo [INFO] Operation cancelled
    )
) else if "%ACTION%"=="destroy" (
    echo [WARNING] This will DESTROY all resources in %ENVIRONMENT% environment
    set /p CONFIRM="Are you sure you want to continue? (y/N): "
    if /i "!CONFIRM!"=="y" (
        echo [INFO] Destroying Terraform resources...
        terraform destroy -var-file="terraform.tfvars" -auto-approve
        echo [SUCCESS] Terraform resources destroyed successfully
    ) else (
        echo [INFO] Operation cancelled
    )
) else if "%ACTION%"=="output" (
    echo [INFO] Showing Terraform outputs...
    terraform output
) else (
    echo [ERROR] Unknown action: %ACTION%
    echo [INFO] Available actions: init, plan, apply, destroy, validate, fmt, output
    exit /b 1
)

echo [SUCCESS] Script completed successfully
