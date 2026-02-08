data "vault_kv_secret_v2" "kv_secret" {
  mount = "kv"
  name  = "temp"
}