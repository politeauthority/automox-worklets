# Reverse Shell v0.0.4
This worklet creates a reverse SSH tunnel from an Automox device to a remote SSH server, allowing
SSH  connections back to the device from the remote server, without exposing the SSH service on the
device to the entire public.

This Worklet has a sister Worklet, 
[Reverse Shell - Disable](./disable-tunnel) which stops the SSH reverse tunnel that this Worklet
creates.

## What This Does
### The Problem
Reverse shells are incredibly useful for maintaining access to a machine which you don't want to
publicly expose to the open internet, or can't due to firewalls or other networking constraints.
However doing this creates it's own issues. Typically this requires the device to run the tunnel
24/7, because you don't have the ability to initiate the tunnel at will without access to the
device.

### The Solution
Automox Worklets can allow you to initiate this secure tunnel at will (as long as the device is
online), as well as terminate that connection. This worklet will create a secure encrypted SSH
tunnel between an Automox device and an SSH server, secured with SSH key pairs. If the device does
not already have a suitable key pair it will create one. The Worklet will also report the device's
public key to the Automox Activity log, so it can be added to your SSH server's authorized keys
file.

## Before You Get Started
This script, though functional, is currently a POC and not suggested for production use. Currently 
it only been throughly tested against Ubuntu 18.04, Fedora 33 and macOS 11. I am hoping to test this
with more operating systems soon.

:warning: **PLEASE BE AWARE:** Running SSH servers explicitly as described in this README can be
very dangerous and is not recommended. This script overly simplifies the nuances of running a public
SSH server. I have put together a section about running an Open SSH server on a linux machine
through a [Docker container](#docker-container-as-ssh-server) which helps alleviate _some_ security
concerns, but is by no means perfect. I will continue to update this Worklet to address security
concerns.

:warning: **ONE DEVICE AT A TIME:** Because this script is in it's infancy, it's recommended to
attach this worklet to only one device at a time for now.

## What You Will Need
 - A device running the Automox agent running an operating system similar to Ubuntu 18.04+, Fedora 33+, macOS 11+.
 - A server publicly available running SSH. :note: In order to forward traffic, your SSH server will
   have to have the config value `AllowTcpForwarding yes` set in your `sshd_config`, typically found in `/etc/ssh/sshd_config`
 - An SSH key pair, with a public key which can be retrieved via `curl`, to be added to the endpoints authorized keys.

## What it Does
 - Checks to see if a tunnel is already running on the device.
 - Checks for an SSH key pair on the device, if one does not exist one is created.
 - Fetches the remote public key of the SSH server/ account the device will be connect to.
 - Report the devices public key value to the Automox Activity Log.
 - Initiate the SSH tunnel between the device and the SSH server on the port defined in `EP_TUNNEL_PORT`

## Worklet Variables
You will need to have criteria for the following variables. These values will be used in the evaluation and remediation steps of the worklet, the will also be used on the remote SSH server to log back into the device over SSH.
| Var Name      | Description | Example |
| ----------- | ----------- |  ----------- |
| `REMOTE_SSH_HOST`      | IP or FQDN of remote server running a SSH server.       | `ssh.example.com` |
| `REMOTE_SSH_PORT`      | Port on remote server running SSH (typically `22`)       | `22` |
| `REMOTE_SSH_USER`      | User on the remote host for device to log in to.       | `root` |
| `REMOTE_PUBLIC_KEY`   | Publicly accessible file containing the public key of the SSH server user, to be added the devices `authorized_keys` file.        | `https://f001.backblazeb2.com/file/example/automox-worklets/reverse-shell-ubuntu.pub` |
| `REMOTE_PRIVATE_KEY`      | Private key file on the remote service which corresponds to the public key `REMOTE_PUBLIC_KEY`  | `/root/data/openssh/keys/automox-remote` |
| `EP_TUNNEL_PORT`      | Port on the device to tunnel with. This is pretty open, `43022` is a good choice.       | `43022` |
| `EP_USER`      | The user on the device initiating the tunnel, for linux and macOs this will always be root and does not need to be set.| `root` |


`REMOTE_PUBLIC_KEY` - This is a file which needs to be accessible from the end point via `curl`.

`EP_TUNNEL_PORT` - This is the port which the endpoint will create the tunnel on, which you will connect on through your SSH server.

## Setup
 - Determine script vars, mentioned above. These values will be used in the [remediate.sh](enable-tunnel/remediate.sh) file and on the remote SSH server to log into the device.
    ```console
    REMOTE_SSH_HOST="ssh.example.com"
    REMOTE_SSH_PORT=2222
    REMOTE_SSH_USER="automox"
    REMOTE_PUBLIC_KEY=https://f001.backblazeb2.com/file/a-public-bucket/automox-worklets/automox-remote.pub
    REMOTE_PRIVATE_KEY="/root/data/openssh/keys/automox-remote"
    EP_TUNNEL_PORT=43022
    ```
 - Create a new worklet for Linux
   - Set the Evaluation segment with [enable-tunnel/evaluate.sh](enable-tunnel/evaluate.sh), this script should not require modification.
   - Set the Remediation segment with [enable-tunnel/remediate.sh](enable-tunnel/remediate.sh) and your unique values from above.
 - Run the worklet on a Linux device.

 - :warning: The first time the worklet runs it will likely error. Check the Automox Activity Log. This is expected because the device's public key has not yet been added to the SSH server's `authorized_keys` file. In the activity log the Details section should have a line that looks similar to the code block below. You will need to run this on the SSH server, so the device's public SSH key is authorized on the SSH server.
     ```console
    echo ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCeGicJWBZRukvhHgwRjy7WttcK0oes4qkfrJvaUuUnSJcVe/hVTOFCjD+NhBBBQy2h3+tfpeSG9FZGbI57o5nwnWOXLQ32z2RKkM0y8Q7Wf7QIIMFnvOs0mKL1v9cgFBPlbzLR/wdVUzWXoYf4jKbVeOWPy9iiZxUhFAQEDyMU/2OPUHhVhT39nPaMV0NQfMEQlSzI0TKC/h5G6soD0aNPysOGkVJapfi9yQRLx7UX6rzVTsznU4xQl+RH3jGEqrjAQIKmnkxbCit40I8wLlggbs2w3KF4uWIpyYVW7JWra2/beKnfQ6F4gVRb9PRxUKhrWWi3OmeQhSMtkL5qy/NZ >> ~/.ssh/authorized_keys
    ```
 - Run the worklet again after adding the devices public SSH key.
 - Login in to the remote server with ssh
 - From the remote server, run the following to SSH to into your device
  ```ssh ${EP_USER}@localhost -p ${EP_TUNNEL_PORT} -i ${REMOTE_PRIVATE_KEY}```

## Tear Down
To ensure termination of the SSH tunnel, you will need to create another Worklet which will
terminate the reverse tunnel on the device. Luckily this is very simple, and should not require any
modification of the scripts provided here.
 - Create a new worklet
 - Copy the data from [Disable Evaluate](disable-tunnel/evaluate.sh) into the evaluation section.
 - Copy the data from [Disable Remediate](disable-tunnel/remediate .sh) into the remediation section.
 - Apply to devices and run as needed.

## Docker Container as SSH Server
This section assumes you have a base line understanding of Docker and have already installed Docker on the server.

### Security Advantages
Running the SSH server your worklet connects to in a Docker container has multiple security advantages.
 - It limits the access the device has to your server. The device will only be connected to a very minimal server, and not have access to the server as a whole.
 - Docker containers can be very ephemeral, and shutdown anytime you don't expect or want remote connections. The server can be shutdown with just `docker stop openssh`.

### Setup and Manage Container
More info about this docker image, and other available options at [https://hub.docker.com/r/linuxserver/openssh-server](https://hub.docker.com/r/linuxserver/openssh-server).
 - **Setup**
 First lets create a directory on your system to persist the containers data, lets say `/home/user/openssh/`, or what we will call `${PERSISTANCE_PATH}`. Here also create a dir called `config` and `keys`. In the `keys` directory put the private and public key that correspond to the `REMOTE_PUBLIC_KEY` used previously, these will be used to connect to the tunnel
 - **Start Container:** 
 Next we will start the Open SSH server container.
    ```console
    REMOTE_SSH_USER=automox
    REMOTE_SSH_PORT=2222
    EP_TUNNEL_PORT=43022
    PERSISTANCE_PATH=/empty/dir/on/ssh-server
    
    docker run -d \
      --name=openssh \
      -e PUID=1000 \
      -e PGID=1000 \
      -e USER_NAME=${REMOTE_SSH_USER} \
      -p ${EP_TUNNEL_PORT}:${EP_TUNNEL_PORT} \
      -p ${REMOTE_SSH_PORT}:${REMOTE_SSH_PORT} \
      -v ${PERSISTANCE_PATH}/config:/config \
      -v ${PERSISTANCE_PATH}/keys:/keys \
      --restart=always \
      ghcr.io/linuxserver/openssh-server
    ```
    `REMOTE_SSH_USER` - The same value as described in [Worklet Variables](#worklet-variables) above.
    
    `REMOTE_SSH_PORT` - The same value as described in [Worklet Variables](#worklet-variables) above.
    
    `EP_TUNNEL_PORT` - The same value as described in [Worklet Variables](#worklet-variables) above.
    
    `PERSISTANCE_PATH` - The path on the machine running the Docker container where we will persist the important values of the container, this where `authorized_keys` and other configuration values where live.

 - **Configure** 
 As mentioned in the [What You Will Need](#what-you-will-need) section, we need to configure the container's SSHD configuration to allow TCP forwarding. To do this edit the file `${PERSISTANCE_PATH}/config/ssh_host_keys/sshd_config` and find the line `AllowTcpForwarding` and set the value to `yes`.
This will require a container restart to take effect. ```docker restart openssh``` :memo: This will kill any active tunnels.
 - **Adding Devices**
 To add your device's public keys, you will now add them to the file `${PERSISTANCE_PATH}/config/.ssh/authorized_keys`. According to the containers documentation, changes to the authorized_keys file to take effect you will also need to restart the container.
 - **Connect**
A this point you should be able to have a device connect to your SSH server running in docker. To connect to the device;
 - Log in to the container, from the server running the container, run `docker exec -it openssh bash`
 - Then run `ssh -o StrictHostKeyChecking=no ${EP_USER}@localhost -p ${EP_TUNNEL_PORT} -i /keys/private_key`
- **Access Tunnel**
Once you have the container up and running and have a device connected, we need to access that tunnel.
From the SSH server run the following.
  - Connect to the OpenSSH docker container, `docker exec -it openssh bash`
  - SSH into the tunnel, this will require the private key portion to the public key you send down to the device that we set with  `REMOTE_PUBLIC_KEY`.
    ```
    ssh \
    -o StrictHostKeyChecking=no \
    ${REMOTE_SSH_USER}@localhost \
    -p ${EP_TUNNEL_PORT} \
    -i /keys/your-private-key
    ```

## Trouble Shooting
If things are not going well, here are some debugging tips.

Checkout the auth logs on your SSH server, for _most_ Debian systems this will be located at `/var/log/auth.log`.
I often use the command `tail -f /var/log/auth.log | grep -i ssh`, so I can watch connections live while I debug.

If you receive the error `ssh_exchange_identification: read: Connection reset by peer` when trying
to connect to your tunnel from the SSH server, this may mean the `${EP_TUNNEL_PORT}` you are using
is already in use, trying killing other tunnel connections, or changing this port.


## Road Map
There are a number of other features I would like to add to this worklet, and I welcome gladly feedback and any help! A couple of things on the radar currently are...
 - Testing on macOS version prior to Big Sur 11.
 - Wider testing on various Linux distros (Ubuntu 20+, Fedora)
 - Better setup instructions.
 - Potential for more control around generating/ supplying SSH keys.
