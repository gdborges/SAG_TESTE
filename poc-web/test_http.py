import paramiko

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

    ssh = create_ssh_client(host, port, user, password)

    # Test HTTP from VPS
    cmd = "curl -s -o /dev/null -w '%{http_code}' http://localhost:5050/Form --max-time 10"
    print(f"Testing: {cmd}")
    stdin, stdout, stderr = ssh.exec_command(cmd)
    stdout.channel.recv_exit_status()
    result = stdout.read().decode('utf-8', errors='replace').strip()
    print(f"HTTP Status: {result}")

    # Test API
    cmd2 = "curl -s http://localhost:5050/api/tables 2>&1 | head -100"
    print(f"\nTesting API: {cmd2}")
    stdin, stdout, stderr = ssh.exec_command(cmd2)
    stdout.channel.recv_exit_status()
    result2 = stdout.read().decode('utf-8', errors='replace')
    print(result2[:500] if len(result2) > 500 else result2)

    ssh.close()

if __name__ == "__main__":
    main()
