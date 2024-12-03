bash -c "vault secrets enable -address=http://127.0.0.1:8100 -path=secret -version=2 kv"

bash -c "vault secrets enable -address=http://127.0.0.1:8100 -path=dev_secret -version=2 kv"

bash -c "vault auth enable -address=http://127.0.0.1:8100 jwt"

bash -c "vault auth enable -address=http://127.0.0.1:8100 userpass"

bash -c "vault kv put -address=http://127.0.0.1:8100 secret/gitlab_ci password=mysecretpassword"

bash -c "vault kv put -address=http://127.0.0.1:8100 dev_secret/developer dbpassword=password"



vault policy write -address=http://127.0.0.1:8100 gitlab_ci_policy - <<EOF
    path "secret/data/*" {
        capabilities = ["read", "list"]
    }
EOF

vault policy write -address=http://127.0.0.1:8100 developer_policy - <<EOF
    path "dev_secret/data/*" {
        capabilities = ["read", "create", "update", "delete", "list"]
    }
EOF

vault write -address=http://127.0.0.1:8100 auth/jwt/config \
    oidc_discovery_url="https://gitlab.com" \
    bound_issuer="https://gitlab.com"

vault write -address=http://127.0.0.1:8100 auth/userpass/users/developer1 \
    password="devopssila" \
    policies="developer_policy"

vault write -address=http://127.0.0.1:8100 auth/jwt/role/test_gitlab - <<EOF
{
  "role_type": "jwt",
  "policies": ["gitlab_ci_policy"],
  "token_explicit_max_ttl": 60,
  "user_claim": "user_email",
  "bound_audiences": "http://167.99.244.46:8100",
  "bound_claims": {
    "project_id": "63108309",
    "ref": "main",
    "ref_type": "branch"
  }
}
EOF