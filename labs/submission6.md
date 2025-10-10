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



## Task 2 — Custom Image Creation & Analysis

### 2.1: Deploy and Customize Nginx

```bash
> docker run -d -p 80:80 --name nginx_container nginx
Unable to find image 'nginx:latest' locally
latest: Pulling from library/nginx
e363695fcb93: Pull complete 
f3ff5b8e6cee: Pull complete 
edd736256ac6: Pull complete 
348644581cc5: Pull complete 
e3e8c796c790: Pull complete 
54959f07be7f: Pull complete 
3766556f3395: Pull complete 
Digest: sha256:3b7732505933ca591ce4a6d860cb713ad96a3176b82f7979a8dfa9973486a0d6
Status: Downloaded newer image for nginx:latest
134f2067691fe5f1603ef0d318004e06aa3d4fb8ef660be9c4e50b4e1b897658
```

```bash
> curl http://localhost
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```

**Create Custom HTML:**

Created file `index.html` with content:

```html
<html>
<head>
<title>The best</title>
</head>
<body>
<h1>website</h1>
</body>
</html>
```


**Copy Custom Content:**

```bash
> docker cp index.html nginx_container:/usr/share/nginx/html/
Successfully copied 2.05kB to nginx_container:/usr/share/nginx/html/
```

```bash
> curl http://localhost
<html>
<head>
<title>The best</title>
</head>
<body>
<h1>website</h1>
</body>
</html>%      
```


### 2.2: Create and Test Custom Image

**Commit Container to Image:**

```bash
> docker commit nginx_container my_website:latest
sha256:b14eae5ef16a25ca01656c29aee9ec227f0c5e10b12d5547b2844a4e63a85107
```


```bash
> docker images my_website
REPOSITORY   TAG       IMAGE ID       CREATED          SIZE
my_website   latest    b14eae5ef16a   31 seconds ago   180MB
```

**Remove Original and Deploy from Custom Image:**

```bash
> docker rm -f nginx_container
nginx_container
```

```bash
> docker run -d -p 80:80 --name my_website_container my_website:latest
946791727e41ba69b810c96576c13e32c124b78ec9e21a0cc7d59a79795f8526
```

```bash
> curl http://localhost
<html>
<head>
<title>The best</title>
</head>
<body>
<h1>website</h1>
</body>
</html>%  
```


**Analyze Filesystem Changes:**

```bash
> docker diff my_website_container
C /etc
C /etc/nginx
C /etc/nginx/conf.d
C /etc/nginx/conf.d/default.conf
C /run
C /run/nginx.pid
```


### Analysis

#### Screenshot or output of original Nginx welcome page

Demonstrated above

#### Custom HTML content and verification

**Custom HTML Content:**
```html
<html>
<head>
<title>The best</title>
</head>
<body>
<h1>website</h1>
</body>
</html>
```

**Verification:** Successfully copied to container and verified via curl showing the custom content replaced the default Nginx welcome page.

#### Output of docker diff analysis

Demonstrated above

#### Analysis: Explain the diff output (A=Added, C=Changed, D=Deleted)

The `docker diff` output shows:

- **C /etc**: Changed directory - likely configuration modifications
- **C /etc/nginx**: Changed nginx configuration directory
- **C /etc/nginx/conf.d**: Changed nginx configuration files directory
- **C /etc/nginx/conf.d/default.conf**: Changed the default nginx configuration file
- **C /run**: Changed runtime directory - nginx creates PID files here
- **C /run/nginx.pid**: Changed nginx process ID file

**Key Observations:**
- **No "A" (Added) entries**: The custom HTML file wasn't detected as added because it replaced an existing file
- **No "D" (Deleted) entries**: No files were deleted during the customization
- **All "C" (Changed) entries**: All changes are modifications to existing files/directories
- **Nginx-specific changes**: The diff shows nginx configuration and runtime files being modified

#### Reflection: Advantages and disadvantages of ```docker commit``` vs Dockerfile for image creation

**Advantages of `docker commit`:**
- **Quick and simple**: Fast way to create images from running containers
- **Interactive development**: Can test changes in real-time before committing
- **No Dockerfile knowledge required**: Easy for beginners to create custom images
- **Immediate results**: Can see changes instantly and commit when satisfied

**Disadvantages of `docker commit`:**
- **No version control**: Changes aren't documented or tracked
- **Not reproducible**: Can't recreate the exact same image on another system
- **Larger image size**: Includes all intermediate changes and temporary files
- **No audit trail**: Can't see what changes were made or when
- **Hard to maintain**: Difficult to update or modify the image later
- **Security concerns**: May include sensitive data or unnecessary files

**Advantages of Dockerfile:**
- **Version control**: Changes are documented and trackable
- **Reproducible**: Can create identical images on any system
- **Layered approach**: Each instruction creates a new layer for optimization
- **Automated builds**: Can be integrated into CI/CD pipelines
- **Best practices**: Enforces proper image building practices
- **Smaller images**: Can optimize layers and remove unnecessary files

**Disadvantages of Dockerfile:**
- **Learning curve**: Requires understanding Dockerfile syntax and best practices
- **Less interactive**: Can't test changes in real-time during development
- **More complex**: Requires planning and understanding of the build process

**When to use each:**
- **Use `docker commit`**: For quick prototyping, testing, or one-off customizations
- **Use Dockerfile**: For production images, team development, or when reproducibility is important