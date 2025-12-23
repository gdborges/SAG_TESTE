import paramiko
import sys

def create_ssh_client(host, port, user, password):
    client = paramiko.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    client.connect(host, port, user, password)
    return client

def main():
    host = "72.60.12.53"
    port = 22
    user = "root"
    password = "GDB0rg3s#270816"

    print(f"Connecting to {host}...")
    ssh = create_ssh_client(host, port, user, password)
    print("Connected!")

    commands = [
        "systemctl status sag-poc --no-pager -l 2>&1 | head -20",
        "journalctl -u sag-poc -n 30 --no-pager 2>&1"
    ]

    for cmd in commands:
        print(f"\n{'='*60}")
        print(f"$ {cmd}")
        print('='*60)
        stdin, stdout, stderr = ssh.exec_command(cmd)
        stdout.channel.recv_exit_status()
        output = stdout.read().decode('utf-8', errors='replace')
        error = stderr.read().decode('utf-8', errors='replace')
        if output:
            # Remove caracteres Unicode que causam problemas no Windows
            output_clean = output.encode('ascii', 'replace').decode('ascii')
            print(output_clean)
        if error:
            error_clean = error.encode('ascii', 'replace').decode('ascii')
            print(f"STDERR: {error_clean}")

    ssh.close()

if __name__ == "__main__":
    main()
