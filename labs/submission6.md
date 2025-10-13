# Lab 6 — Container Fundamentals with Docker
---

## Tasks

### Task 1 — Container Lifecycle & Image Management (3 pts)

#### 1.1: Basic Container Operations

1. **List Existing Containers:**

   ```sh
   docker ps -a
   ```
<img width="808" height="52" alt="image" src="https://github.com/user-attachments/assets/5d9ae984-e8ae-4409-97d5-f906bf75de9f" />

2. **Pull Ubuntu Image:**

   ```sh
   docker pull ubuntu:latest
   docker images ubuntu
   ```
<img width="844" height="206" alt="image" src="https://github.com/user-attachments/assets/13bb4f9e-0426-4a84-9150-763f93399f6f" />

3. **Run Interactive Container:**
  
   ```sh
   docker run -it --name ubuntu_container ubuntu:latest
   ```

   Inside the container, explore:
   - Check OS version: `cat /etc/os-release`
   - List processes: `ps aux`
   - Exit with `exit`

<img width="1351" height="577" alt="image" src="https://github.com/user-attachments/assets/638d05f7-5a5e-4a7d-a4c2-b819ae468778" />


#### 1.2: Image Export and Dependency Analysis

1. **Export the Image:**

   ```sh
   docker save -o ubuntu_image.tar ubuntu:latest
   ls -lh ubuntu_image.tar
   ```
   
<img width="1093" height="113" alt="image" src="https://github.com/user-attachments/assets/fb1d0730-8c09-48d6-9a7e-c74c937d134d" />

2. **Attempt Image Removal:**

   ```sh
   docker rmi ubuntu:latest
   ```
- Error message from the first removal attempt
  
<img width="1253" height="54" alt="image" src="https://github.com/user-attachments/assets/d3d30b61-eeef-4bef-a0df-334ed98fa841" />

3. **Remove Container and Retry:**

   ```sh
   docker rm ubuntu_container
   docker rmi ubuntu:latest
   ```
   
 <img width="755" height="204" alt="image" src="https://github.com/user-attachments/assets/4fd6889e-5126-41c5-9e25-a97ae019278b" />

### Analysis

**Image Size and Layer Information:**
- **Image Size**: 78.1MB (from `docker images`)
- **Tar File Size**: 77M (slightly smaller)
- **Layers**: 1 visible layer (`4b3ffd8ccb52`)
**Tar file size comparison with image size**
The 77M tar file is slightly smaller than the 78.1MB image due to different measurement units (MB vs MiB) and compression during export.
<img width="280" height="74" alt="image" src="https://github.com/user-attachments/assets/9baec3dc-0056-4b5d-a8be-0179b3e7f21e" />

**Why does image removal fail when a container exists? (Explain the dependency relationship)**

Docker establishes a parent-child relationship. When a container exists, it holds references to the image layers, preventing accidental deletion.
To sucsess: Step 1: Remove Container --> Step 2: Remove Image

**Explanation: What is included in the exported tar file?**

The exported tar contains the blueprint of the image, not the runtime state of containers. `docker save` creates a portable archive of a Docker image, including its layers and metadata(including configuration details, history, and layers necessary to reconstruct the image) it does NOT include the running state or data of any containers based on that image.

---

### Task 2 — Custom Image Creation & Analysis (3 pts)

**Objective:** Create custom images from running containers and understand filesystem changes.

#### 2.1: Deploy and Customize Nginx

1. **Deploy Nginx Container:**

   ```sh
   docker run -d -p 80:80 --name nginx_container nginx
   curl http://localhost
   ```
   <img width="848" height="280" alt="image" src="https://github.com/user-attachments/assets/6d5895fc-7387-4ed3-b045-562b165b2c36" />
<img width="760" height="533" alt="image" src="https://github.com/user-attachments/assets/5126891e-9df6-4886-b151-67ad48456c14" />


2. **Create Custom HTML:**

   Create a file named `index.html` with the following content:

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
   
<img width="405" height="198" alt="image" src="https://github.com/user-attachments/assets/08a8b939-93ae-479c-9d69-2d00b645c75d" />


3. **Copy Custom Content:**

   ```sh
   docker cp index.html nginx_container:/usr/share/nginx/html/
   curl http://localhost
   ```
   
<img width="699" height="218" alt="image" src="https://github.com/user-attachments/assets/d7103486-d4b6-4dca-b208-1307989ba5da" />

The page updated successfully. Replacing `/usr/share/nginx/html/index.html` worked correctly.


#### 2.2: Create and Test Custom Image

1. **Commit Container to Image:**

   ```sh
   docker commit nginx_container my_website:latest
   docker images my_website
   ```

2. **Remove Original and Deploy from Custom Image:**

   ```sh
   docker rm -f nginx_container
   docker run -d -p 80:80 --name my_website_container my_website:latest
   curl http://localhost
   ```

3. **Analyze Filesystem Changes:**

   ```sh
   docker diff my_website_container
   ```
<img width="918" height="554" alt="image" src="https://github.com/user-attachments/assets/81937924-a08f-4b31-ae52-964bf3c0c81c" />

   <details>
   <summary>🔍 Understanding docker diff output</summary>

   - `A` = Added file or directory
   - `C` = Changed file or directory
   - `D` = Deleted file or directory

   </details>

### Analysis

**Reflection: What are the advantages and disadvantages of `docker commit` vs Dockerfile for image creation?**

**`docker commit` vs `Dockerfile`:**

`docker commit` - Fast for testing, captures current state, but lacks reproducibility and audit trail. 

`Dockerfile` - Better for production - reproducible, version-controlled, optimized layers

Best practice: using commit only for debugging

---

### Task 3 — Container Networking & Service Discovery (2 pts)

**Objective:** Explore Docker's built-in networking and DNS-based service discovery.

#### 3.1: Create Custom Network

1. **Create Bridge Network:**

   ```sh
   docker network create lab_network
   docker network ls
   ```
   
<img width="486" height="130" alt="image" src="https://github.com/user-attachments/assets/6fc71630-1b9e-47d2-95e9-28ed866e7747" />

2. **Deploy Connected Containers:**

   ```sh
   docker run -dit --network lab_network --name container1 alpine ash
   docker run -dit --network lab_network --name container2 alpine ash
   ```
   
<img width="613" height="154" alt="image" src="https://github.com/user-attachments/assets/562755f7-18d8-497e-89e3-e8be8d133092" />

Containers: Successfully deployed `container1` and `container2`

#### 3.2: Test Connectivity and DNS

1. **Test Container-to-Container Communication:**

   ```sh
   docker exec container1 ping -c 3 container2
   ```
<img width="448" height="148" alt="image" src="https://github.com/user-attachments/assets/e7d8b2c0-d00c-404b-bb58-3732dcb5259c" />


:tada: **successful ping connectivity**

2. **Inspect Network Details:**

   ```sh
   docker network inspect lab_network
   ```
   
<img width="746" height="762" alt="Снимок экрана 2025-10-12 202711" src="https://github.com/user-attachments/assets/adf05488-2b3f-4d1c-991e-454ffc969bea" />

3. **Check DNS Resolution:**

   ```sh
   docker exec container1 nslookup container2
   ```
   
```sh
vboxuser@lab456:~$ docker exec container1 nslookup container2
Server:		127.0.0.11
Address:	127.0.0.11:53

Non-authoritative answer:

Non-authoritative answer:
Name:	container2
Address: 172.18.0.3
```

### Analysis

**- Network inspection output showing both containers' IP addresses**

- container1: 172.18.0.2/16
- container2: 172.18.0.3/16

**- Analysis: How does Docker's internal DNS enable container-to-container communication by name?**

Docker runs a built-in DNS server (127.0.0.11) in each container that automatically resolves container names to IP addresses within the same network, enabling service discovery by name instead of hardcoded IPёs.

**- Comparison: What advantages does user-defined bridge networks provide over the default bridge network?**

User-defined: Automatic DNS, better isolation, custom configuration

Default bridge: Manual linking required, less secure, fixed configuration

Advantage: User-defined networks provide automatic service discovery and enhanced security

---

### Task 4 — Data Persistence with Volumes (2 pts)

**Objective:** Understand data persistence across container lifecycles using Docker volumes.

#### 4.1: Create and Use Volume

1. **Create Named Volume:**

   ```sh
   docker volume create app_data
   docker volume ls
   ```

2. **Deploy Container with Volume:**

   ```sh
   docker run -d -p 80:80 -v app_data:/usr/share/nginx/html --name web nginx
   ```

3. **Add Custom Content:**

   Create a custom `index.html` file:

   ```html
   <html><body><h1>Persistent Data</h1></body></html>
   ```

   Copy to volume:

   ```sh
   docker cp index.html web:/usr/share/nginx/html/
   curl http://localhost
   ```
   
<img width="862" height="194" alt="image" src="https://github.com/user-attachments/assets/2d45f4a7-ea19-40ba-a294-66b4ca2e8e56" />

#### 4.2: Verify Persistence

1. **Destroy and Recreate Container:**

   ```sh
   docker stop web && docker rm web
   docker run -d -p 80:80 -v app_data:/usr/share/nginx/html --name web_new nginx
   curl http://localhost
   ```

   <img width="907" height="153" alt="image" src="https://github.com/user-attachments/assets/9394ca2f-72b6-4cd6-a482-616dacd5bc02" />


2. **Inspect Volume:**

   ```sh
   docker volume inspect app_data
   ```

<img width="603" height="248" alt="image" src="https://github.com/user-attachments/assets/b150d498-a2dd-4e5b-822f-48a609744c09" />

### Analysis

In `labs/submission6.md`, document:

✅  Custom HTML content used
✅  Output of curl showing content persists after container recreation
✅  Volume inspection output showing mount point

**- Analysis: Why is data persistence important in containerized applications?**

Containers are disposable and stateless and tthey can be destroyed/recreated at any time. Without persistence, all data is lost when container stopуed/updated/failed.

**- Comparison: Explain the differences between volumes, bind mounts, and container storage.**

Named volumes are volumes which you create manually with `docker volume create VOLUME_NAME`. They are created in `/var/lib/docker/volumes` and can be referenced to by only their name.
Volumes managed by Docker, provide better performance, easy to make backups

Bind mounts are basically just binding a certain directory or file from the host inside the container. Offer direct host access but less portable across diff OS.

Container storage is the writable layer that exists only during the container's lifetime. It provides the fastest access but all data is lost when the container stops.

**When would you use each?**

- volumes for production persistence(databases, user dataa)
- bind mounts for development flexibility
- container storage only for temporary data((temporary files, cache data, etc. that can be safely lost when the container stops)
