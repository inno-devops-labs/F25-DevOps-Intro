# Lab 5 — Virtualization & System Analysis

![difficulty](https://img.shields.io/badge/difficulty-intermediate-yellow)
![topic](https://img.shields.io/badge/topic-Virtualization-blue)
![points](https://img.shields.io/badge/points-10-orange)

> **Goal:** Learn virtualization fundamentals by deploying VMs and analyzing system specifications across different platforms.
> **Deliverable:** A PR from `feature/lab5` to the course repo with `labs/submission5.md` containing VM deployment documentation and system analysis. Submit the PR link via Moodle.

---

## Overview

In this lab you will practice:
- Setting up virtualization platforms across different operating systems.
- Deploying and configuring virtual machines with modern Linux distributions.
- Using command-line tools for system information gathering and analysis.
- Documenting virtualization workflows for cross-platform environments.

These skills are essential for DevOps infrastructure management and system administration.

---

## Tasks

### Task 1 — VirtualBox Installation (5 pts)

**Objective:** Install VirtualBox on your host operating system.

#### 1.1: Install VirtualBox

1. **Download and Install:**

   - Download VirtualBox from [https://www.virtualbox.org/](https://www.virtualbox.org/)
   - Install using the GUI installer with default settings
   - Restart if prompted

2. **Verify Installation:**

   - Launch VirtualBox and note the version number

In `labs/submission5.md`, document:
- Host operating system and version (e.g., "Windows 11 Pro 23H2", "macOS Sonoma 14.1", "Ubuntu 22.04 LTS")
- VirtualBox version number
- Any installation issues encountered

### Task 2 — Ubuntu VM and System Analysis (5 pts)

**Objective:** Deploy Ubuntu 24.04 LTS in VirtualBox and discover tools to analyze system information.

#### 2.1: Create Ubuntu VM

1. **VM Setup:**

   - Download Ubuntu 24.04 LTS ISO from [https://ubuntu.com/download/desktop](https://ubuntu.com/download/desktop)
   - Create new VM in VirtualBox with:
     - RAM: 4GB minimum (8GB recommended)
     - Storage: 25GB minimum
     - CPU: 2 cores minimum
   - Install Ubuntu using the default installation process

#### 2.2: System Information Discovery

1. **Find Tools to Gather Information:**

   Research and discover command-line tools that can provide:
   - **CPU Details**: Processor model, architecture, cores, frequency
   - **Memory Information**: Total RAM, available memory
   - **Network Configuration**: IP addresses, network interfaces
   - **Storage Information**: Disk usage, filesystem details
   - **Operating System**: Ubuntu version, kernel information
   - **Virtualization Detection**: Confirmation system is running in a VM

In `labs/submission5.md`, document:
- VM configuration specifications used (RAM, storage, CPU cores)
- For each information type above:
  - Tool name(s) you discovered
  - Command(s) used
  - Complete command output
- Brief reflection on which tools were most useful and why

---

## Acceptance Criteria

- ✅ Branch `feature/lab5` exists with commits for each task.
- ✅ File `labs/submission5.md` contains required outputs and analysis for Tasks 1-2.
- ✅ VirtualBox is successfully installed and verified.
- ✅ Ubuntu 24.04 LTS VM is deployed and documented.
- ✅ System analysis shows comprehensive hardware and OS information.
- ✅ PR from `feature/lab5` → **course repo main branch** is open.
- ✅ PR link submitted via Moodle before the deadline.

---

## How to Submit

1. Create a branch for this lab and push it to your fork:

   ```bash
   git switch -c feature/lab5
   # create labs/submission5.md with your findings
   git add labs/submission5.md
   git commit -m "docs: add lab5 submission"
   git push -u origin feature/lab5
   ```

2. Open a PR from your fork's `feature/lab5` branch → **course repository's main branch**.

3. In the PR description, include:

   ```text
   - [x] Task 1 done
   - [x] Task 2 done
   ```

4. **Copy the PR URL** and submit it via **Moodle before the deadline**.

---

## Rubric (10 pts)

| Criterion                                      | Points |
| ---------------------------------------------- | -----: |
| Task 1 — VirtualBox installation              |   **5** |
| Task 2 — Ubuntu VM + system analysis          |   **5** |
| **Total**                                      |  **10** |

---

## Guidelines

- Use clear Markdown headers to organize sections in `submission5.md`.
- Include complete command outputs with proper formatting.
- Document your tool discovery process and reasoning.

> **Installation Notes**  
> 1. Download software only from official websites.  
> 2. Use default installation settings unless you have specific requirements.  
> 3. Ensure your host system has sufficient resources before creating VMs.

> **Tool Discovery Tips**  
> 1. Start with built-in Linux commands before installing additional packages.  
> 2. Use package managers (apt) to search for system information tools.  
> 3. Test multiple tools and compare their outputs.  
> 4. Document which tools provide the most useful information.


---

## 🧪 **Hands-On Lab: WASM Container vs Regular Container**

### 🎯 **Lab Objective**: Build a Moscow Time Web App and Compare WASM vs Regular Containers

**📋 What You'll Learn:**
- 🐍 Create a Python Flask web app
- 🌐 Convert Python app to WebAssembly
- 🐳 Run WASM containers with Docker
- 📊 Compare startup times and resource usage
- ⚡ Experience the WASM advantage

---

### 📝 **Step 1: Create the Moscow Time Web App**

**Create project structure:**
```bash
# Create project directory
mkdir moscow-time-app
cd moscow-time-app

# Create Python files
touch app.py requirements.txt
```

**📄 app.py - Simple Flask app showing Moscow time:**
```python
from flask import Flask, jsonify
from datetime import datetime
import pytz

app = Flask(__name__)

@app.route('/')
def home():
    return '''
    <html>
    <head><title>Moscow Time</title></head>
    <body style="font-family: Arial; text-align: center; margin-top: 100px;">
        <h1>🕰️ Current Time in Moscow</h1>
        <p><a href="/api/time">Get JSON API</a></p>
        <script>
            async function updateTime() {
                const response = await fetch('/api/time');
                const data = await response.json();
                document.getElementById('time').innerHTML = 
                    `<h2>${data.moscow_time}</h2>`;
            }
            setInterval(updateTime, 1000);
        </script>
        <div id="time">Loading...</div>
    </body>
    </html>
    '''

@app.route('/api/time')
def get_moscow_time():
    moscow_tz = pytz.timezone('Europe/Moscow')
    moscow_time = datetime.now(moscow_tz)
    return jsonify({
        'moscow_time': moscow_time.strftime('%Y-%m-%d %H:%M:%S %Z'),
        'timestamp': moscow_time.timestamp()
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
```

**📄 requirements.txt:**
```
Flask==2.3.3
pytz==2023.3
```

---

### 🐳 **Step 2: Traditional Docker Container**

**📄 Dockerfile (Traditional):**
```dockerfile
FROM python:3.11-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

EXPOSE 8080
CMD ["python", "app.py"]
```

**🔨 Build and run traditional container:**
```bash
# Build traditional container
docker build -t moscow-time-traditional .

# Run and measure startup time
time docker run --rm -p 8080:8080 moscow-time-traditional

# Test in browser: http://localhost:8080
```

---

### 🌐 **Step 3: WASM Container with Docker**

**📄 Dockerfile.wasm:**
```dockerfile
# Use Python WASM base image
FROM --platform=wasi/wasm python:3.11-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

EXPOSE 8080
CMD ["python", "app.py"]
```

**🔨 Build and run WASM container:**
```bash
# Enable Docker WASM support (if not already enabled)
docker buildx create --use --name wasm-builder

# Build WASM container
docker buildx build --platform wasi/wasm -t moscow-time-wasm -f Dockerfile.wasm .

# Run WASM container and measure startup
time docker run --rm --runtime=io.containerd.wasmedge.v1 \
  --platform=wasi/wasm -p 8081:8080 moscow-time-wasm

# Test in browser: http://localhost:8081
```

---

### 📊 **Step 4: Performance Comparison**

**⚡ Startup Time Benchmark:**
```bash
#!/bin/bash
# benchmark.sh - Compare startup times

echo "🐳 Testing Traditional Container Startup..."
for i in {1..5}; do
    echo "Run $i:"
    time docker run --rm moscow-time-traditional python -c "print('Container started')"
done

echo "🌐 Testing WASM Container Startup..."
for i in {1..5}; do
    echo "Run $i:"
    time docker run --rm --runtime=io.containerd.wasmedge.v1 \
      --platform=wasi/wasm moscow-time-wasm python -c "print('WASM started')"
done
```

**📏 Size Comparison:**
```bash
# Compare image sizes
docker images | grep moscow-time

# Expected results:
# moscow-time-traditional  ~150MB
# moscow-time-wasm        ~50MB (66% smaller!)
```

**🧠 Memory Usage Comparison:**
```bash
# Monitor resource usage
docker stats

# Run both containers simultaneously and compare:
# Traditional: ~50MB RAM
# WASM:       ~20MB RAM (60% less!)
```

---

### 🔧 **Step 5: Advanced WASM Features**

**🌐 Using WasmEdge Runtime directly:**
```bash
# Install WasmEdge
curl -sSf https://raw.githubusercontent.com/WasmEdge/WasmEdge/master/utils/install.sh | bash

# Compile Python to WASM (advanced)
wasmedge --dir .:. python.wasm app.py
```

**🎯 Alternative: Use Spin Framework for WASM:**
```bash
# Install Spin
curl -fsSL https://developer.fermyon.com/downloads/install.sh | bash

# Create Spin app
spin new http-py moscow-time-spin --accept-defaults
cd moscow-time-spin

# Modify app.py with Moscow time logic
# Deploy locally
spin build
spin up
```

---

### 🎯 **Expected Results & Discussion**

**📊 Performance Comparison Table:**

| Metric | 🐳 Traditional Container | 🌐 WASM Container | 🚀 Improvement |
|--------|-------------------------|------------------|----------------|
| **Startup Time** | ~2-5 seconds | ~100-500ms | **5-10x faster** |
| **Image Size** | ~150MB | ~50MB | **66% smaller** |
| **Memory Usage** | ~50MB | ~20MB | **60% less** |
| **Security** | OS-level isolation | WASM sandbox | **Enhanced** |

**🤔 Discussion Questions:**
1. **Why is the WASM container so much faster to start?**
2. **What are the trade-offs? What can't WASM do that containers can?**
3. **When would you choose WASM vs traditional containers?**
4. **How does this change your thinking about serverless functions?**

**⚠️ Current Limitations:**
- 🔒 Limited system access (no direct file system, limited networking)
- 🐍 Not all Python packages work (no native extensions)
- 🧪 Still experimental ecosystem
- 🔧 Fewer debugging tools

**🚀 Future Potential:**
- ⚡ Perfect for serverless functions
- 🌐 Ideal for edge computing
- 🔒 Enhanced security for multi-tenant applications
- 🌍 Universal deployment across platforms

---

### 🎓 **Lab Challenges (Optional)**

**🥉 Bronze Challenge**: Add more timezones (Tokyo, London, New York)

**🥈 Silver Challenge**: Create a REST API that accepts timezone as parameter

**🥇 Gold Challenge**: Build the same app in different languages (Go, Rust, JavaScript) and compare WASM performance

**🏆 Platinum Challenge**: Deploy to a real edge computing platform (Fastly Compute@Edge, Cloudflare Workers)

---

### 📚 **Additional Resources**
* [Docker WASM Documentation](https://docs.docker.com/desktop/wasm/)
* [WasmEdge Runtime](https://wasmedge.org/)
* [Fermyon Spin Framework](https://spin.fermyon.dev/)
* [Python to WASM Guide](https://github.com/wasmerio/python-ext-wasm)

---

**💡 Pro Tip**: This lab demonstrates why WASM is revolutionizing serverless computing - imagine deploying thousands of these Moscow time functions that start in microseconds instead of seconds!

---

**🎉 Congratulations! You've successfully:**
- ✅ Built a Python web application
- ✅ Containerized it traditionally and with WASM
- ✅ Compared performance metrics
- ✅ Experienced the future of lightweight virtualization

**🚀 Next Steps**: Try deploying this to a cloud platform that supports WASM containers and see the difference in cold start times for serverless functions!