import os
import sys
import urllib.request
from pathlib import Path
import progressbar
import urllib.request
from scripts import settings
import subprocess


pbar = None


def show_progress(block_num, block_size, total_size):
    global pbar
    if pbar is None:
        pbar = progressbar.ProgressBar(maxval=total_size)
        pbar.start()

    downloaded = block_num * block_size
    if downloaded < total_size:
        pbar.update(downloaded)
    else:
        pbar.finish()
        pbar = None


config = settings.get_config()


def download_prerequisites():
    cached = Path(config["prerequisites"]["save_location"]+"/.cached")
    print("downloading prerequisites.", flush=True)
    if cached.is_file():
        print("download cached, skipping downloads", flush=True)
    else:
        for pkg in config["prerequisites"]["pkgs"]:
            print(f"downloading: {pkg['pkg_name']}", flush=True)
            urllib.request.urlretrieve(
                pkg["pkg_url"], config["prerequisites"]["save_location"] + pkg["pkg_name"], show_progress)
        cached.touch()
        print("finished", flush=True)


def find_container(container_name, shutdown=False):
    s = subprocess.check_output(
        f"docker ps {'-a' if shutdown else ''}", shell=True)
    return str(s).find(container_name) != -1


def build_container():
    print("building docker image", flush=True)
    download_prerequisites()
    os.system("docker build -f dockerfiles/Dockerfile -t oracle-db:18cXE .")


def create_container(cached=False):
    print("creating docker container")
    if not cached:
        download_prerequisites()
    # add this if you want to expose web -p 5500:5500
    os.system(
        f"docker run -d -p 41061:22 -p 1521:1521 -h {config['container_name']} --name {config['container_name']} oracle-db:18cXE")

def install_db():
    if find_container(config["container_name"], shutdown=True):
        print("Oracle Database is already installed.", flush=True)
        return
    else:
        print("installing db", flush=True)
        download_prerequisites()
        build_container(cached=True)
        create_container()
    print("NOTE:     the default DB password is 'ORADBXE18c'", flush=True)


def uninstall_db():
    if find_container(config["container_name"], shutdown=True):
        os.system(f"docker rm {config['container_name']}")
        print("Uninstalling", flush=True)
        stop_database()
    else:
        print("Container is not installed, Skipping.")


def run_rql_plus():
    if find_container(config["container_name"]):
        os.system(
            f'docker exec -it {config["container_name"]} sh -c "sqlplus"')
    else:
        print("Container not found/running.")


def start_database():
    if find_container(config["container_name"]):
        print("Container already running.")
    else:
        print("Starting oracle service", flush=True)
        os.system(f"docker start {config['container_name']}")
        print("Started oracle service", flush=True)


def stop_database():
    if find_container(config["container_name"]):
        print("Stopping oracle service", flush=True)
        os.system(f"docker stop {config['container_name']}")
        print("Stopped oracle service", flush=True)
    else:
        print("Container already stopped.")


options = {
    "1": build_container,
    "2": install_db,
    "3": uninstall_db,
    "4": run_rql_plus,
    "5": start_database,
    "6": stop_database,
    "7": lambda: sys.exit(0)
}


def main():
    if config is not None:
        print(f"""OS: {config['platform']['type']} [{"NON" if not config['platform']['unix_like'] else ""} UNIX]
----------------------------
| ORACLE DATABASE 18C XE   |
----------------------------
|        MENU              |
----------------------------
1. Build Container
2. Install Database
3. Uninstall Database
4. SQLPLUS
5. Start Database
6. Stop Database
7. Exit""")
    print("----------------------------")
    option = input("select option [1-6]: ")
    option = options.get(option, (lambda: print("Invalid option")))
    option()


if __name__ == "__main__":
    main()
