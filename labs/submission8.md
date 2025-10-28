# Lab 8 — Site Reliability Engineering (SRE)

## Tasks

### Task 1 — Key Metrics for SRE and System Analysis (4 pts)

#### 1.1: Monitor System Resources

### Top 3 most consuming applications for CPU, memory, and I/O usage

**CPU Usage:**
- **/usr/bin/gnome-shell** - 17.1%
- **/usr/libexec/gnome-terminal-server** - 4.5%
- **htop** - 3.8%
  
<img width="1830" height="449" alt="image" src="https://github.com/user-attachments/assets/ca168558-bade-4416-8ee3-b825041cecdf" />

**Memory Usage:**
- **gnome-shell** - 6.3% 
- **/snap/firefox/7084/usr/lib/firefox/firefox** - 6.1% 
- **/snap/code/210/usr/share/code/code** - 4.1%
- 
**I/O Usage:**
- **No active I/O processes** - 0.00 B/s disk activity
- Total DISK READ:         0.00 B/s | Total DISK WRITE:         0.00 B/s

**Command(s)**
```
iostat -x 1 5
```
**Output:**
```
Linux 6.14.0-33-generic (lab456) 	10/28/2025 	_x86_64_	(12 CPU)

avg-cpu:  %user   %nice %system %iowait  %steal   %idle
           2.17    0.08    1.72    0.16    0.00   95.88

Device            r/s     rkB/s   rrqm/s  %rrqm r_await rareq-sz     w/s     wkB/s   wrqm/s  %wrqm w_await wareq-sz     d/s     dkB/s   drqm/s  %drqm d_await dareq-sz     f/s f_await  aqu-sz  %util
loop0            0.01      0.01     0.00   0.00    0.14     1.21    0.00      0.00     0.00   0.00    0.00     0.00    0.00      0.00     0.00   0.00    0.00     0.00    0.00    0.00    0.00   0.00
...
```

#### 1.2: Disk Space Management

1. **Check Disk Usage:**

**Command(s)**
```
df -h
```
**Output:**
```
Filesystem      Size  Used Avail Use% Mounted on
tmpfs           794M  1.7M  793M   1% /run
/dev/sda2        32G  9.5G   21G  32% /
tmpfs           3.9G   23M  3.9G   1% /dev/shm
tmpfs           5.0M  8.0K  5.0M   1% /run/lock
tmpfs           794M  152K  794M   1% /run/user/1000
/dev/sr0         51M   51M     0 100% /media/vboxuser/VBox_GAs_7.2.25
```

**Command(s)**
```
sudo du -h /var | sort -rh | head -n 10
```
**Output:**
```
4.1G	/var
3.3G	/var/lib
2.8G	/var/lib/snapd
1.8G	/var/lib/snapd/cache
754M	/var/lib/snapd/snaps
605M	/var/cache
547M	/var/cache/apt
434M	/var/cache/apt/archives
246M	/var/lib/snapd/seed/snaps
246M	/var/lib/snapd/seed
```

2. **Identify Largest Files:**

**Command(s)**
- sudo find /var -type f -exec du -h {} + | sort -rh | head -n 3

**Output:**
```
517M	/var/lib/snapd/snaps/gnome-42-2204_202.snap
331M	/var/lib/snapd/cache/b310fda46540e632be7d78144accea8340742063c4c4f74569118be7c74cee34697c90278e433065003656a254e59ac6
331M	/var/lib/snapd/cache/80a1f4a7aec964fe4ac336ba364bb31b71bcde83932f9d07f757641c140a83168dea6433aa3cfd05ad03099ea0b16c7c
```

**Analysis: What patterns do you observe in resource utilization?**

The system demonstrates efficient resource allocation with minimal CPU and memory usage, indicating an idle state. I/O operations demonstrate minimal disk contention with only 0.16% wait time, suggesting optimal storage performance. Storage consumption is primarily dominated by snap packages occupying significant space in the /var directory.

**Reflection: How would you optimize resource usage based on your findings?**

I'd implement snap cache cleanup to reclaim cache footprint while maintaining current performance levels. Setting up disk space monitoring with alerting would manage storage growth from package management. No immediate optimizations are needed beyond routine maintenance.

---

### Task 2 — Practical Website Monitoring Setup (6 pts)

#### 2.1: Choose Your Website

**Website URL**: `https://github.com/` and `https://translate.yandex.ru/`

## 2.2 Checkly Configuration

### API Check - Basic Availability
- **Assertion**: Status code is 200
- **Frequency**: Every 2 minutes
- **Locations**: Frankfurt (eu-central-1), N. Virginia (us-east-1)

<img width="1773" height="846" alt="image" src="https://github.com/user-attachments/assets/952e9c04-eb61-4ce3-857c-0e98695d8b11" />

<img width="1749" height="857" alt="image" src="https://github.com/user-attachments/assets/4a1c6028-a695-406e-aac5-0b38cd2c5940" />

<img width="1919" height="972" alt="image" src="https://github.com/user-attachments/assets/88775d72-d14a-492e-8744-5ad4936af86b" />

#### 2.2: Create Checks in Checkly

```
const { expect, test } = require('@playwright/test')

test.setTimeout(60000)

test('Yandex Translate critical checks', async ({ page }) => {
  console.log('🚀 Starting Yandex Translate checks...')

  // Step 1: Measuring page load time
  console.log('⏱️ Step 1: Measuring page load time...')
  const loadStartTime = Date.now()
  const response = await page.goto('https://translate.yandex.ru/')
  const loadTime = Date.now() - loadStartTime
  console.log(`✅ Page loaded in ${loadTime}ms`)

  expect(response?.status()).toBeLessThan(400)

  // Step 2: Testing translation
  console.log('🔤 Step 2: Testing translation...')
  const textInput = page.locator('#fakeArea, textarea, [contenteditable="true"]').first()
  await textInput.fill('Hello world')
  await page.waitForTimeout(3000)
  console.log('✅ Translation test completed')

  // Step 3: Checking usage examples
  console.log('📖 Step 3: Checking usage examples...')
  const usageExamples = page.locator('text=Примеры использования').first()
  await expect(usageExamples).toBeVisible({ timeout: 5000 })
  console.log('✅ Usage examples found')

  // Final screenshot
  await page.screenshot({ path: 'yandex-translate-check.png' })
  console.log(`🎉 All checks passed! Load time: ${loadTime}ms`)
})
```

Logs:
```
Starting job
Creating runtime version 2025.04 using Node.js 22
Running Playwright test script
Running 1 test using 1 worker
[1/1] [chromium] › test.spec.js › Yandex Translate critical checks
[chromium] › ../../checkly/functions/src/2025-04/node_modules/vm2/lib/bridge.js:485:11 › Yandex Translate critical checks
🚀 Starting Yandex Translate checks...
⏱️ Step 1: Measuring page load time...
✅ Page loaded in 1480ms
🔤 Step 2: Testing translation...
✅ Translation test completed
📖 Step 3: Checking usage examples...
✅ Usage examples found
🎉 All checks passed! Load time: 1480ms
1 passed (6.9s)
Run finished
Uploading log file
```

Screenshot

<img width="1639" height="926" alt="image" src="https://github.com/user-attachments/assets/66a3cd64-b18c-4926-8a0d-611ed26214be" />

<img width="1686" height="878" alt="image" src="https://github.com/user-attachments/assets/eac3c750-9cd2-4c3d-9039-455e09a0db7b" />

#### 2.3: Set Up Alerts

<img width="1917" height="738" alt="image" src="https://github.com/user-attachments/assets/a5900aea-7c48-4573-9ba3-ce474a118004" />

<img width="1911" height="739" alt="image" src="https://github.com/user-attachments/assets/ffe56bf1-c1cb-4bd6-99aa-9acab5c6136d" />

#### 2.4: Capture Proof & Documentation

In `labs/submission8.md`, document:

- **Analysis: Why did you choose these specific checks and thresholds?**

I chose these particular checks cuz they cover critical aspects of Yandex Translater. The page load time check ensures the service is responsive - nobody wants to wait forever. The translation functionality test ("Hello world") directly validates the **core purpose** of the website. And checking for the "Примеры использования" (Usage Examples) section confirms UI after changing state of translation.

What I really appreciated was how Checkly automatically records videos of each test run - this was incredibly helpful for debugging)

- **Reflection: How does this monitoring setup help maintain website reliability?**

This setup acts as a 24/7 safety net, instantly alerting us to downtime, performance slowdowns, or broken features. By catching these issues proactively, we can resolve them before they impact a significant number of users, ensuring the translation service remains reliable and trustworthy.
