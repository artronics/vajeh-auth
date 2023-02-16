import os
import subprocess

from invoke import task

ENV_FILE = ".env"


def read_kvm():
    try:
        with open(ENV_FILE) as f:
            kv = {k.strip(): v.strip() for k, v in (line.split('=') for line in f if line.strip())}
            return kv
    except ValueError:
        print("Parse error. Format file like key=value")
        exit(1)
    except FileNotFoundError:
        print("Environment file not found. Create .env file by renaming example.env file")
        exit(1)


kvm = read_kvm()
# .env kvm will overwrite environment variables
os.environ.update(kvm)


def get_state_s3_name():
    prj = kvm['PROJECT']
    account = "ptl" if kvm['ENVIRONMENT'] != "prod" else "prod"
    return f"{prj}-{account}-terraform-state"


TERRAFORM_STATE_S3 = get_state_s3_name()


def parse_workspace_list(output):
    workspaces = []
    current_ws = None
    for ws in output.split("\n"):
        _ws = ws.strip()
        if _ws.startswith("*"):
            current_ws = _ws.lstrip("*").strip()
            workspaces.append(current_ws)
        elif _ws != "":
            workspaces.append(_ws)
    return workspaces, current_ws


def get_terraform_workspaces(_dir) -> (list[str], str):
    s = subprocess.check_output(["terraform", f"-chdir={_dir}", "workspace", "list"])
    return parse_workspace_list(s.decode("utf-8"))


def switch_workspace(_dir, ws):
    subprocess.run(["terraform", f"-chdir={_dir}", "workspace", "select", ws])


def create_workspace(_dir, ws):
    subprocess.run(["terraform", f"-chdir={_dir}", "workspace", "new", ws])


@task(help={"dir": "Directory where terraform files are located. Set default via TERRAFORM_DIR in env var or .env file",
            "ws": "Terraform workspace. Set default via WORKSPACE in env var or .env file"})
def workspace(c, dir=kvm["TERRAFORM_DIR"], ws=kvm["WORKSPACE"]):
    (wss, current_ws) = get_terraform_workspaces(dir)
    if ws not in wss:
        create_workspace(dir, ws)
    elif ws != current_ws:
        switch_workspace(dir, ws)


@task(help={"dir": "Directory where terraform files are located. "
                   "Set default via TERRAFORM_DIR in env var or .env file"})
def init(c, dir=kvm["TERRAFORM_DIR"]):
    c.run(f"terraform -chdir={dir} init -backend-config=\"bucket={TERRAFORM_STATE_S3}\"")


@task(workspace)
def plan(c, dir=kvm["TERRAFORM_DIR"]):
    c.run(f"terraform -chdir={dir} plan")


@task(workspace)
def apply(c, dir=kvm["TERRAFORM_DIR"]):
    c.run(f"terraform -chdir={dir} apply")
