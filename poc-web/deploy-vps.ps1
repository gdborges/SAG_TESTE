$password = ConvertTo-SecureString 'GDB0rg3s#270816' -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential('root', $password)
$session = New-SSHSession -ComputerName '72.60.12.53' -Credential $credential -AcceptKey
$result = Invoke-SSHCommand -SessionId $session.SessionId -Command 'systemctl stop sag-poc; rm -rf /opt/sag-poc/*; cd /opt && tar -xzf sag-poc-linux.tar.gz -C sag-poc && chmod +x /opt/sag-poc/SagPoc.Web && systemctl start sag-poc && sleep 2 && systemctl status sag-poc'
$result.Output
Remove-SSHSession -SessionId $session.SessionId
