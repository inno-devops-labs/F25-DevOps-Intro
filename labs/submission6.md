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

2. **Attempt Image Removal:**

   ```sh
   docker rmi ubuntu:latest
   ```

3. **Remove Container and Retry:**

   ```sh
   docker rm ubuntu_container
   docker rmi ubuntu:latest
   ```
   
<img width="1556" height="445" alt="image" src="https://github.com/user-attachments/assets/c82970a3-9352-4de5-9b6a-958371b4d443" />

### Analysis

**Image Size and Layer Information:**
- **Image Size**: 78.1MB (from `docker images`)
- **Tar File Size**: 77M (slightly smaller)
- **Layers**: 1 visible layer (`4b3ffd8ccb52`)
**Tar file size comparison with image size???**

**Analysis: Why does image removal fail when a container exists? (Explain the dependency relationship)**

**Explanation: What is included in the exported tar file?**


In `labs/submission6.md`, document:
- Output of `docker ps -a` and `docker images`
- Image size and layer count
- Tar file size comparison with image size
- Error message from the first removal attempt



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

3. **Copy Custom Content:**

   ```sh
   docker cp index.html nginx_container:/usr/share/nginx/html/
   curl http://localhost
   ```
<img width="915" height="470" alt="image" src="https://github.com/user-attachments/assets/3b626f09-f081-4f46-86ad-90ccd9231e79" />

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

In `labs/submission6.md`, document:
- Screenshot or output of original Nginx welcome page
- Custom HTML content and verification via curl
- Output of `docker diff my_website_container`
- Analysis: Explain the diff output (A=Added, C=Changed, D=Deleted)
- Reflection: What are the advantages and disadvantages of `docker commit` vs Dockerfile for image creation?

---

### Task 3 — Container Networking & Service Discovery (2 pts)

**Objective:** Explore Docker's built-in networking and DNS-based service discovery.

#### 3.1: Create Custom Network

1. **Create Bridge Network:**

   ```sh
   docker network create lab_network
   docker network ls
   ```

2. **Deploy Connected Containers:**

   ```sh
   docker run -dit --network lab_network --name container1 alpine ash
   docker run -dit --network lab_network --name container2 alpine ash
   ```

#### 3.2: Test Connectivity and DNS

1. **Test Container-to-Container Communication:**

   ```sh
   docker exec container1 ping -c 3 container2
   ```

2. **Inspect Network Details:**

   ```sh
   docker network inspect lab_network
   ```

3. **Check DNS Resolution:**

   ```sh
   docker exec container1 nslookup container2
   ```

In `labs/submission6.md`, document:
- Output of ping command showing successful connectivity
- Network inspection output showing both containers' IP addresses
- DNS resolution output
- Analysis: How does Docker's internal DNS enable container-to-container communication by name?
- Comparison: What advantages does user-defined bridge networks provide over the default bridge network?
<img width="710" height="431" alt="image" src="https://github.com/user-attachments/assets/c451819c-d5f7-451e-a89a-21038285efa0" />
<img width="746" height="762" alt="image" src="https://github.com/user-attachments/assets/d365e655-aeb5-4d5f-bc93-27d1c419826c" />

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

#### 4.2: Verify Persistence

1. **Destroy and Recreate Container:**

   ```sh
   docker stop web && docker rm web
   docker run -d -p 80:80 -v app_data:/usr/share/nginx/html --name web_new nginx
   curl http://localhost
   ```

2. **Inspect Volume:**

   ```sh
   docker volume inspect app_data
   ```

In `labs/submission6.md`, document:
- Custom HTML content used
- Output of curl showing content persists after container recreation
- Volume inspection output showing mount point
- Analysis: Why is data persistence important in containerized applications?
- Comparison: Explain the differences between volumes, bind mounts, and container storage. When would you use each?

<img width="1806" height="751" alt="image" src="https://github.com/user-attachments/assets/5aec41b5-b746-4efa-8980-fea4a7ea8bcc" />

---
