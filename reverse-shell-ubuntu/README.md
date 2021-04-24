# Reverse Shell - Ubuntu
This worklet creates a reverse shell from an Automox device to a remote SSH server, allowing SSH 
connections back to the device from the remote server, without exposing the SSH service on the
device to the entire public.

## Before You Get Started
:warning: This script is currently a POC and not suggested for production use. It's currently tested against Ubuntu 18.04 and nothing else. *PLEASE BE AWARE* Running SSH servers explicity as described in this README can be very dangerous and is not recommended. This script overly simplifies the nuiances of running a public SSH server. (Hopefully in time I can create more secure examples.)

## What You Will Need
 - A device running the Automox agent (Ubuntu 18.04).
 - A server publicly available running SSH.
 - A publicly available public key for the SSH sever, to be added to the endpoints authorized keys.

## Details
You will need to have details for the following varriables. These values will be used in the evaluation and remediation steps of the worklet, the will also be used on the remote SSH server to log back into the device over SSH.
| Var Name      | Description | Example |
| ----------- | ----------- |  ----------- |
| `REMOTE_SSH_HOST`      | IP or FQDN of remote server running a SSH server.       | `ssh.example.com` |
| `REMOTE_SSH_PORT`      | Port on remote server running SSH (typically `22`)       | `22` |
| `REMOTE_SSH_USER`      | User on the remote host for device to log in to.       | `root` |
| `REMOTE_PUBLIC_KEY`   | Publically accessible file containing the public key of the SSH server user, to be added the devices `authorized_keys` file.        | `https://f001.backblazeb2.com/file/example/automox-worklets/reverse-shell-ubuntu.pub` |
| `REMOTE_PRIVATE_KEY`      | Private key file on the remote service which corresponds to the public key `REMOTE_PUBLIC_KEY`  | `/root/data/openssh/keys/automox-remote` |
| `EP_TUNNEL_PORT`      | Port on the device to tunnel with. This is pretty open, `43022` is a good choice.       | `43022` |
| `EP_USER`      | User on the device to run the tunnel as.       | `root` |

## Setup
 - Determine script vars, these values will be used in the `remediation.sh` file and on the remote SSH server, to log into the device.
    ```console
    REMOTE_SSH_HOST="ssh.example.com"
    REMOTE_SSH_PORT=22
    REMOTE_SSH_USER="root"
    REMOTE_PUBLIC_KEY=https://f001.backblazeb2.com/file/example/automox-worklets/reverse-shell-ubuntu.pub
    REMOTE_PRIVATE_KEY="/root/data/openssh/keys/automox-remote"
    EP_TUNNEL_PORT=43022
    EP_USER="root"
    ```
 - Create a new worklet for Linux
   - Set the Evaluation segment with `evaluation.sh` and your unique values from above.
   - Set the Remediation segment with `remediation.sh` and your unique values from above.
 - Run the worklet on a Ubuntu device.
 - :warning: The first time the worklet runs it will likely error. Check the Automox Activity Log. This is expected because the device's public key has not yet been added to the SSH server's `authorized_keys` file. In the activity log the Details section should have a line that looks similar to the code block below. You will need to run this on the SSH server, so the device's public SSH key is authorized on the SSH server.
     ```console
    echo ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCeGicJWBZRukvhHgwRjy7WttcK0oes4qkfrJvaUuUnSJcVe/hVTOFCjD+NhBBBQy2h3+tfpeSG9FZGbI57o5nwnWOXLQ32z2RKkM0y8Q7Wf7QIIMFnvOs0mKL1v9cgFBPlbzLR/wdVUzWXoYf4jKbVeOWPy9iiZxUhFAQEDyMU/2OPUHhVhT39nPaMV0NQfMEQlSzI0TKC/h5G6soD0aNPysOGkVJapfi9yQRLx7UX6rzVTsznU4xQl+RH3jGEqrjAQIKmnkxbCit40I8wLlggbs2w3KF4uWIpyYVW7JWra2/beKnfQ6F4gVRb9PRxUKhrWWi3OmeQhSMtkL5qy/NZ >> ~/.ssh/authorized_keys
    ```
 - Run the worklet again after adding the devices public SSH key.
 - Login in to the remote server with ssh
 - From the remote server, run the following to SSH to into your device
  ```ssh ${EP_USER}@localhost -p ${EP_TUNNEL_PORT} -i ${REMOTE_PRIVATE_KEY}```


## Testing
To test this I spun up a VPS in digital ocean running ubuntu 18.04, installed Automox and then ran the worklet on that machine.
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
