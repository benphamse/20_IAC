resource "aws_instance" "aws_example" {
  ami           = "ami-0b8607d2721c94a77"
  instance_type = "t2.micro"

  tags = {
    Secret = data.vault_kv_secret_v2.kv_secret.data["test"]
    # Replace "secret_key" with the actual key you want to retrieve from Vault
  }
}