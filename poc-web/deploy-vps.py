import paramiko

host = '72.60.12.53'
user = 'root'
password = 'GDB0rg3s#270816'

commands = [
    'systemctl stop sag-poc',
    'rm -rf /opt/sag-poc/*',
    'cd /opt && tar -xzf sag-poc-linux.tar.gz -C sag-poc',
    'chmod +x /opt/sag-poc/SagPoc.Web',
    'systemctl start sag-poc',
    'sleep 2',
    'systemctl status sag-poc'
]

client = paramiko.SSHClient()
client.set_missing_host_key_policy(paramiko.AutoAddPolicy())

try:
    print(f"Connecting to {host}...")
    client.connect(host, username=user, password=password)
    print("Connected!")

    for cmd in commands:
        print(f"\nExecuting: {cmd}")
        stdin, stdout, stderr = client.exec_command(cmd)
        out = stdout.read().decode()
        err = stderr.read().decode()
        if out:
            print(out)
        if err:
            print(f"STDERR: {err}")

    print("\nDeploy completed!")
finally:
    client.close()
