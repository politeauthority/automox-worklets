# Woklet: Reverse Shell - Ubuntu
This worklet creates a reverse shell from an Automox device to a remote SSH server, allowing SSH 
connections back to the device from the remote server, without exposing the SSH service on the
device to the public internet.


## What You Will Need
 - A device running the Automox agent (Ubuntu 18.04).
 - A server publicly available running SSH.
 - A key pair to share between the server and device.

## Details
You will need to have details for the following varriables. These values will be used in the evaluation and remediation steps of the worklet, the will also be used on the remote SSH server to log back into the device over SSH.
| Var Name      | Description |
| ----------- | ----------- |
| `REMOTE_SSH_HOST`      | IP or FQDN of remote server running a SSH server.       |
| `REMOTE_SSH_USER`      | User on the remote host for device to log in to.       |
| `REMOTE_SSH_PORT`      | Port on remote server running SSH (typically `22`)       |
| `REMOTE_PUBLIC_KEY`   | Publically accessible file containing the public key of the SSH server user, to be added the devices `authorized_keys` file. (ex: `https://f001.backblazeb2.com/file/example/automox-worklets/reverse-shell-ubuntu.pub`        |
| `REMOTE_PRIVATE_KEY`      | Private key file on the remote service which corresponds to the public key `REMOTE_PUBLIC_KEY`  |
| `EP_TUNNEL_PORT`      | Port on the device to tunnel with. This is pretty open, `43022` is a good choice.       |
| `EP_USER`      | User on the device to run the tunnel as.       |
| `EP_SSH_PRIVATE_KEY`   | Private key file on the device to use when logging into the remote SSH server.        |
| `EP_SSH_PUBLIC_KEY`   | ex `/root/.ssh/id_rsa.pub`        |

## Setup
 - Determine script vars, these values will be used in the `evaluation.sh`, `remediation.sh` and on the remote SSH server, to log into the device.
    ```console
    REMOTE_SSH_USER="automox-device-shell"
    REMOTE_SSH_HOST="ssh.example.com"
    REMOTE_SSH_PORT=22
    REMOTE_PUBLIC_KEY=https://f001.backblazeb2.com/file/example/automox-worklets/reverse-shell-ubuntu.pub
    REMOTE_PRIVATE_KEY="/home/automox-device-shell/data/openssh/keys/automox-remote"
    EP_TUNNEL_PORT=43022
    EP_USER=admin
    EP_SSH_PRIVATE_KEY=/home/admin/.ssh/id_rsa
    EP_SSH_PUBLIC_KEY=/root/.ssh/id_rsa.pub
    ```
 - Create a new worklet, filling out the evaluation segment with `evaluation.sh` and your unique values.
   - Set the Evaluation segment with `evaluation.sh` and your unique values from above.
   - Set the Remediation segment with `remediation.sh` and your unique values from above.
 - Run the worklet on a Ubuntu device.
 - Login in to the remote server with ssh
 - From the remote server, running the following to SSH to into your device
  ```ssh ${EP_USER}@localhost -p ${EP_TUNNEL_PORT} -i ${REMOTE_PRIVATE_KEY}```


## Testing
 - Spin up 18.04 digital ocean droplet
 - SSH to box
 - Install Automox
  ```curl -sS "https://console.automox.com/downloadInstaller?accesskey=your-key" | bash```
  ```service amagent start```

 - Add device to group with worklet
 - Run system updates
 - Run worklet
 - Copy public key to SSH Services authorized_keys
 - Run worklet again
 - Connect to device from SSH server
