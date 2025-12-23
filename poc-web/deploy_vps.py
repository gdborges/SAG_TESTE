import paramiko
from scp import SCPClient
import sys

def create_ssh_client(host, port, user, password):
    client = paramiko.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    client.connect(host, port, user, password)
    return client

def progress(filename, size, sent):
    percent = (sent / size) * 100
    print(f"\rUploading {filename}: {percent:.1f}% ({sent}/{size} bytes)", end='', flush=True)

def main():
    host = "72.60.12.53"
    port = 22
    user = "root"
    password = "GDB0rg3s#270816"

    local_file = r"C:\Users\geraldo.borges\CascadeProjects\SAG\poc-web\SagPoc.Web\sag-poc-linux.tar.gz"
    remote_path = "/opt/sag-poc-linux.tar.gz"

    print(f"Connecting to {host}...")
    ssh = create_ssh_client(host, port, user, password)
    print("Connected!")

    # Upload file
    print(f"\nUploading {local_file} to {remote_path}...")
    with SCPClient(ssh.get_transport(), progress=progress) as scp:
        scp.put(local_file, remote_path)
    print("\nUpload complete!")

    # Deploy commands
    commands = [
        "systemctl stop sag-poc",
        "rm -rf /opt/sag-poc/*",
        "cd /opt && tar -xzf sag-poc-linux.tar.gz -C sag-poc",
        "chmod +x /opt/sag-poc/SagPoc.Web",
        "systemctl start sag-poc",
        "sleep 2",
        "systemctl status sag-poc --no-pager"
    ]

    print("\nExecuting deployment commands...")
    for cmd in commands:
        print(f"\n$ {cmd}")
        stdin, stdout, stderr = ssh.exec_command(cmd)
        exit_status = stdout.channel.recv_exit_status()
        output = stdout.read().decode()
        error = stderr.read().decode()
        if output:
            print(output)
        if error:
            print(f"STDERR: {error}")

    ssh.close()
    print("\nDeployment complete!")

if __name__ == "__main__":
    main()
