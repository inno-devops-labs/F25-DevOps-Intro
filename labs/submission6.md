# Lab 6 — Container Fundamentals with Docker

## Task 1 — Container Lifecycle & Image Management

### 1.1: Basic Container Operations

**List Existing Containers:**

```bash
> docker ps -a
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
```

**Pull Ubuntu Image:**

```bash
> docker pull ubuntu:latest
latest: Pulling from library/ubuntu
b8a35db46e38: Pull complete 
Digest: sha256:59a458b76b4e8896031cd559576eac7d6cb53a69b38ba819fb26518536368d86
Status: Downloaded newer image for ubuntu:latest
docker.io/library/ubuntu:latest
```

```bash
> docker images ubuntu
REPOSITORY   TAG       IMAGE ID       CREATED      SIZE
ubuntu       latest    e149199029d1   9 days ago   101MB
```

**Run Interactive Container:**

```bash
> docker run -it --name ubuntu_container ubuntu:latest
```

**Inside the container exploration:**

```bash
> cat /etc/os-release
PRETTY_NAME="Ubuntu 24.04.3 LTS"
NAME="Ubuntu"
VERSION_ID="24.04"
VERSION="24.04.3 LTS (Noble Numbat)"
VERSION_CODENAME=noble
ID=ubuntu
ID_LIKE=debian
HOME_URL="https://www.ubuntu.com/"
SUPPORT_URL="https://help.ubuntu.com/"
BUG_REPORT_URL="https://bugs.launchpad.net/ubuntu/"
PRIVACY_POLICY_URL="https://www.ubuntu.com/legal/terms-and-policies/privacy-policy"
UBUNTU_CODENAME=noble
LOGO=ubuntu-logo
```

```bash
> ps aux
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root         1  0.0  0.0   4296  3484 pts/0    Ss   17:45   0:00 /bin/bash
root        10  0.0  0.0   7628  3456 pts/0    R+   17:46   0:00 ps aux
```


### 1.2: Image Export and Dependency Analysis

**Export the Image:**

```bash
> docker save -o ubuntu_image.tar ubuntu:latest
> ls -lh ubuntu_image.tar
-rw-------@ 1 ivanilicev  staff    98M Oct 10 20:49 ubuntu_image.tar
```


**Attempt Image Removal:**

```bash
> docker rmi ubuntu:latest
Error response from daemon: conflict: unable to remove repository reference "ubuntu:latest" (must force) - container 6409af1e65f4 is using its referenced image e149199029d1
```


**Remove Container and Retry:**

```bash
> docker rm ubuntu_container
ubuntu_container
```

```bash
> docker rmi ubuntu:latest
Untagged: ubuntu:latest
Untagged: ubuntu@sha256:59a458b76b4e8896031cd559576eac7d6cb53a69b38ba819fb26518536368d86
Deleted: sha256:e149199029d15548c4f6d2666e88879360381a2be8a1b747412e3fe91fb1d19d
Deleted: sha256:ab34259f9ca5d315bec1b17d9f1ca272e84dedd964a8988695daf0ec3e0bbc2e
```


### Analysis

### All outputs are provided above

#### Image size and layer count

The Ubuntu image size is **101MB** as one can see in ```docker images``` output. The image was created 9 days ago. The pull output shows one layer is downloaded: b8a35db46e38, clearly demonstrating it is a single layer image.

#### Tar file size comparison

The exported tar file ```ubuntu_image.tar``` is **98MB**, which is a bit smaller than the reported Docker image size of 101MB. This difference occurs because:

- **Compression**: The tar file uses compression algorithms that can reduce the overall size
- **Metadata overhead**: Docker images include additional metadata that may not be fully compressed in the tar
- **Layer deduplication**: The tar export process may optimize layer storage
- **File system differences**: Different storage formats between Docker's internal representation and tar archive



#### Analysis: Why does image removal fail when a container exists?

The image removal fails because of Docker's **dependency management system**:

- **Container Dependency**: The container ```ubuntu_container``` is still referencing the image ```ubuntu:latest```
- **Safety Mechanism**: Docker prevents deletion of images that are actively being used by containers
- **Filesystem Sharing**: Containers share the image's filesystem layers, so deleting the image would break the container
- **Error Message**: "container 6409af1e65f4 is using its referenced image e149199029d1" clearly shows the dependency
- **Resolution**: Must remove the container first (```docker rm ubuntu_container```) before removing the image

This demonstrates Docker's **copy-on-write (COW)** filesystem where containers reference image layers rather than copying them.


#### Explanation: What is included in the exported tar file?

The exported tar file contains:

- **All Image Layers**: Every filesystem layer that makes up the Ubuntu image
- **Layer Metadata**: JSON configuration files for each layer describing changes
- **Image Manifest**: File that describes the image structure and layer relationships
- **Repository Information**: Tag information and repository references
- **Layer Archives**: Compressed tar files containing the actual filesystem changes for each layer


This tar file can be used to **restore the exact image** on another Docker host using `docker load -i ubuntu_image.tar`.

