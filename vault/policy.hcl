# Policy for the Flask application
# Grants read access to app secrets only

path "secret/data/gemops/app" {
  capabilities = ["read"]
}

path "secret/metadata/gemops/app" {
  capabilities = ["read", "list"]
}

# Deny access to anything else
path "*" {
  capabilities = ["deny"]
}