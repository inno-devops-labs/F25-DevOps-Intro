# Lab 6 — Container Fundamentals with Docker

## Task 1 — Container Lifecycle & Image Management

### 1.1: Basic Container Operations

**List Existing Containers:**

Command:

```bash
docker ps -a
```

Output:

```bash
CONTAINER ID   IMAGE                              COMMAND                  CREATED        STATUS                    PORTS     NAMES
52e0c39051e6   deployment-streamlit               "streamlit run strea…"   13 days ago    Exited (0) 13 days ago              streamlit_app
d4a514c5859c   deployment-fastapi                 "uvicorn app:app --h…"   13 days ago    Exited (0) 13 days ago              fastapi_service
cfea53ca891b   part2-backend                      "python3 /backend/ba…"   2 weeks ago    Exited (0) 2 weeks ago              part2-backend-1
cc5ca22649eb   part2-frontend                     "streamlit run /fron…"   2 weeks ago    Exited (0) 2 weeks ago              part2-frontend-1
4092a7b2e811   semitechnologies/weaviate:1.24.4   "/bin/weaviate --hos…"   3 months ago   Exited (0) 3 months ago             datasetpreparing-weaviate-1
```

**Pull Ubuntu Image:**

Command

```bash
docker pull ubuntu:latest
docker images ubuntu
```

Output

```bash
latest: Pulling from library/ubuntu
7bdf644cff2e: Pull complete 
Digest: sha256:728785b59223d755e3e5c5af178fab1be7031f3522c5ccd7a0b32b80d8248123
Status: Downloaded newer image for ubuntu:latest
docker.io/library/ubuntu:latest
REPOSITORY   TAG       IMAGE ID       CREATED      SIZE
ubuntu       latest    728785b59223   7 days ago   139MB
```

**Run Interactive Container:**

Command

```bash
docker run -it --name ubuntu_container ubuntu:latest
```

**Inside the container exploration:**

Commands

```bash
cat /etc/os-release
ps aux
exit
```

Outputs

```bash
> PRETTY_NAME="Ubuntu 24.04.3 LTS"
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

> USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root         1  0.0  0.0   4296  3612 pts/0    Ss   19:01   0:00 /bin/bash
root        10  0.0  0.0   7628  3468 pts/0    R+   19:02   0:00 ps aux
```

### 1.2: Image Export and Dependency Analysis

**Export the Image:**

Commands

```bash
docker save -o ubuntu_image.tar ubuntu:latest
ls -lh ubuntu_image.tar
```

Output

```bash
-rw-------@ 1 rail  staff    28M Oct  7 22:05 ubuntu_image.tar
```

**Attempt Image Removal:**

Command

```bash
docker rmi ubuntu:latest
```

Output

```bash
Error response from daemon: conflict: unable to delete ubuntu:latest (must be forced) - container 22290317e64e is using its referenced image 728785b59223
```

**Remove Container and Retry:**

Commands

```bash
docker rm ubuntu_container
docker rmi ubuntu:latest
```

Output

```bash
ubuntu_container
Untagged: ubuntu:latest
Deleted: sha256:728785b59223d755e3e5c5af178fab1be7031f3522c5ccd7a0b32b80d8248123
```

### Analysis

### Output of docker ps -a and docker images, same as Error message from the first removal attempt, provided above

#### Image size and layer count

The Ubuntu image size is **139MB** as shown in the `docker images` output. The image was created 7 days ago and uses the latest tag. The pull output shows one layer being downloaded (7bdf644cff2e), indicating this is a single-layer image.

#### Tar file size comparison

The exported tar file (`ubuntu_image.tar`) is **28MB**, which is significantly smaller than the reported Docker image size of 139MB. This difference occurs because:

- Tar file contains compressed layers
- Docker's reported size includes uncompressed filesystem layers

#### Analysis: Why does image removal fail when a container exists?

Docker prevents image removal when containers (even stopped ones) depend on that image because:

- Containers maintain a reference to their base image
- Removing the image would break the container's ability to restart
- The image contains the filesystem layers that the container needs

#### Explanation: What is included in the exported tar file?

The exported tar file contains:

- All filesystem layers that make up the image
- Image metadata and configuration
- Layer manifests and checksums
- Repository and tag information
- The complete image structure needed to recreate the image on another system

The tar file is typically larger than the reported image size because it includes uncompressed layers and metadata overhead.
