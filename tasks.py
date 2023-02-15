import os

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


def get_value(k) -> str:
    if k in kvm:
        return kvm[k]
    elif os.environ.get(k):
        return os.environ[k]
    else:
        print(f"Can not find {k} in either .env file or environment variable")


@task
def init(c):
    c.run("terraform -chdir=terraform init")


if __name__ == '__main__':
    print(kvm)
    # print(get_value("WORKSPACEs"))
    print(os.environ["WORKSPACE"])
