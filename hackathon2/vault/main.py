import json
import sys
import os
import subprocess

def get_vault_config():
    vault_addr =  "http://137.184.180.202:8200"
    vault_token = "root"
    return vault_addr, vault_token

def get_secret_from_vault(field):
    vault_addr, vault_token = get_vault_config()

    env = os.environ.copy()
    env["VAULT_ADDR"] = vault_addr
    env["VAULT_TOKEN"] = vault_token

    result = subprocess.run(
        ["vault", "kv", "get", f"-field={field}", "secret/hackakaton"],
        stdout=subprocess.PIPE,
        text=True,
        env=env,
        check=True
    )
    return result.stdout.strip()
url = get_secret_from_vault("url")
user= get_secret_from_vault("user")
password = get_secret_from_vault("password")
