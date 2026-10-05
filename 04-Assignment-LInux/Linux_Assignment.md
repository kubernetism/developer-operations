# LINUX SYSTEMS ENGINEERING & DEVOPS

**Practical Engineering Assignment**

*Case Studies • Troubleshooting • Automation • Production Reliability*

| | |
| --- | --- |
| Target audience | Linux Engineers / Junior DevOps Engineers |
| Difficulty | Intermediate → Advanced |
| Submission | Written answers + terminal evidence/screenshots where requested |
| Environment | Ubuntu/Debian recommended; RHEL/Rocky/Fedora equivalents may be used |
| Total | 100 marks |

> **Note on the tips:** Every question below has a **📚 Study first** line. It lists the commands/concepts to learn before attempting that question. The tips are not answers.

---

## Assignment Brief

This assignment evaluates practical Linux engineering skills covered in the supplied Linux quickstart and systems-engineering handbooks. It focuses on file and permission management, system monitoring, firewall and cURL troubleshooting, package management, cron automation, systemd service administration, logging, port diagnostics, inode and memory failures, and storage I/O troubleshooting.

Students should answer as engineers: explain the reasoning behind commands, use safe operational practices, and distinguish between diagnosis and remediation.

## Learning Outcomes

- Navigate Linux filesystems and manipulate files/directories safely.
- Apply chmod/chown correctly and explain ownership and permission implications.
- Diagnose CPU, memory, disk, process, and network-port issues.
- Configure UFW without accidentally locking out SSH access.
- Use cURL to validate HTTP endpoints and troubleshoot application connectivity.
- Manage packages reliably in Ubuntu/Debian and understand equivalent package-manager concepts.
- Create reliable cron-based automation using absolute paths, logging, and flock.
- Create and operate production-style systemd services with least privilege and resource controls.
- Use journalctl, ss, nc, df -i, dmesg, and iostat to investigate production failures.

## Submission Rules

- For command questions, provide the command and a one-sentence explanation.
- For troubleshooting cases, show: **symptoms → evidence/commands → root cause → remediation → prevention**.
- Do not use destructive commands on a production server. Use a VM/lab environment.
- Where a question asks for terminal evidence, include a screenshot or copied output.
- Use absolute paths in automation wherever practical and consider cron's minimal environment.

---

## Section A — Linux Fundamentals & Permissions (15 marks)

**1.** You are connected to a Linux server and need to confirm your current location, inspect hidden files, and move to `/etc/nginx`. Write the commands. **[3 marks]**

> 📚 **Study first:** `pwd`, `ls` (and its `-a` / `-l` flags), `cd`, and how to chain commands with `&&`.

**2.** Create the directory tree `/opt/company/app/logs` in one command. Then create an empty file named `application.log` inside it. **[2 marks]**

> 📚 **Study first:** `mkdir` (the flag that creates parent directories), `touch`, and using a full path vs. `cd` first.

**3.** Explain the difference between `chmod 755`, `chmod 644`, and `chmod 600`. Give one realistic DevOps use case for each. **[4 marks]**

> 📚 **Study first:** `chmod` numeric (octal) mode: r=4, w=2, x=1; the user/group/others triplet; `ls -l` to read permission strings; `stat`. Think about scripts, config files, and SSH private keys.

**4.** A deployment script exists at `/opt/deploy/run.sh` but returns "Permission denied" when executed. Give two safe commands you would use to diagnose/fix the issue. **[3 marks]**

> 📚 **Study first:** `ls -l`, `stat`, `namei -l` (checks permissions along the whole path), `chmod +x` / `chmod u+x`, `id`, `whoami`.

**5.** The application files under `/var/www` are owned by root, but the web service account needs to manage them. Write the recursive ownership command and explain the risk of changing ownership blindly. **[4 marks]**

> 📚 **Study first:** `chown` and `chown -R` (user:group syntax), `chgrp`, `id`, `ls -ld`. Read about why recursive changes on the wrong path (e.g. `/`, symlinks) are dangerous.

**6.** Why should `rm -rf` be treated as a high-risk command? Give two safer operational practices before using it. **[4 marks]**

> 📚 **Study first:** `rm` and its flags (`-r`, `-f`, `-i`, `-I`), `ls` / `echo` / `find ... -print` to preview what a path or glob matches, `pwd`, shell variable expansion pitfalls (empty variable in `rm -rf $VAR/`).

---

## Section B — System Monitoring & Network Troubleshooting (15 marks)

**7.** A Python API is reported as "down" on an Ubuntu server. Write the command sequence you would use to determine whether the Python process is running, whether port 8000 is listening, whether UFW permits the traffic, and whether the API responds locally. **[4 marks]**

> 📚 **Study first:** `ps aux | grep`, `pgrep`, `systemctl status`, `ss -tlnp`, `ufw status` (verbose / numbered), `curl localhost:8000/health`. Remember the question says **Ubuntu**, so use the Ubuntu firewall tool.

**8.** Explain what `htop`/`top`, `free -m`, `df -h`, `ps aux`, and `ss -tulpn` provide. Which tool would you use first for each of: high CPU, low RAM, full disk, missing process, port conflict? **[4 marks]**

> 📚 **Study first:** Read the output columns of each tool: `top`/`htop` (%CPU, load average), `free -m` (available vs. free), `df -h` (Use%, mount point), `ps aux` (PID, USER, STAT), `ss -tulpn` (state, local address, process).

**9.** You can access the Python API locally with `curl http://localhost:8000/health`, but users cannot access it remotely. List at least four diagnostic checks and explain what each would prove or disprove. **[4 marks]**

> 📚 **Study first:** `ss -tlnp` (is it bound to `127.0.0.1` or `0.0.0.0`?), `ufw status`, `curl` using the server's own IP, `nc -zv` from another machine, `ip a`, `ping`, `traceroute`, and cloud/network-level security groups.

**10.** Write cURL commands for: (a) checking only HTTP headers/status, (b) verbose troubleshooting, and (c) sending a JSON POST request to the Python API. **[2 marks]**

> 📚 **Study first:** `curl -I`, `curl -v`, `curl -X POST` with `-H "Content-Type: application/json"` and `-d '{...}'`. Look at the `/api/users` endpoint and `User` model in the provided `main.py` for the JSON body.

**11.** Why is it important to allow SSH before enabling UFW on a remote server? Provide the relevant rule. **[1 mark]**

> 📚 **Study first:** `ufw allow` (by port and by service name), `ufw enable`, `ufw status verbose`, and UFW's default incoming policy.

---

## Section C — Package Management & Production Installation (10 marks)

**12.** On Ubuntu/Debian, write a production-oriented command sequence to update repository metadata and install nginx, curl, and jq non-interactively. **[2 marks]**

> 📚 **Study first:** `apt-get update`, `apt-get install -y`, the `DEBIAN_FRONTEND=noninteractive` environment variable, and the difference between `apt` and `apt-get` in scripts. Note: `update` vs. `upgrade` are different operations.

**13.** Explain why package repository metadata should be synchronized before installation. **[2 marks]**

> 📚 **Study first:** What `apt-get update` actually downloads (package index lists, not packages), `/etc/apt/sources.list` and `sources.list.d`, and what happens with stale indexes (404 errors, old versions).

**15.** Give the equivalent package-management operations for Ubuntu/Debian, RHEL/Rocky/Fedora, and Alpine for: install, remove, upgrade, and list installed files. **[3 marks]**

> 📚 **Study first:** `apt` / `dpkg -L`, `dnf` / `rpm -ql`, and `apk` (`apk add`, `apk del`, `apk upgrade`, `apk info -L`). Build a 3-column comparison table while you study.
>
> *(The original document has no question 14; numbering is kept as-is.)*

---

## Section D — Cron Automation (10 marks)

**16.** Write a cron expression to run a backup every night at 2:00 AM. **[1 mark]**

> 📚 **Study first:** The 5 cron fields (minute, hour, day-of-month, month, day-of-week), `crontab -e`, `crontab -l`.

**17.** Write a cron entry that runs `/opt/scripts/healthcheck.sh` every five minutes and appends both stdout and stderr to `/var/log/healthcheck.log`. **[2 marks]**

> 📚 **Study first:** The `*/N` step syntax, `>>` (append) vs. `>` (overwrite), `2>&1` and why its position matters, and running a script via its absolute path.

**18.** A backup cron job sometimes overlaps with the previous run, causing high CPU and disk usage. Explain how `flock -n` solves this problem and provide a suitable command pattern. **[3 marks]**

> 📚 **Study first:** `man flock`: lock file, `-n` (non-blocking), what exit code it returns when the lock is already held, and where lock files conventionally live (`/var/lock` or `/run/lock`).

**19.** Why can a script work interactively but fail under cron? Identify the environment/PATH issue and give a mitigation. **[2 marks]**

> 📚 **Study first:** `echo $PATH` in your shell vs. cron's default minimal `PATH`, `which` / `command -v`, setting `PATH=` or `SHELL=` at the top of a crontab, and using absolute paths everywhere.

**20.** Design a reliable cron-based backup workflow. Include: script safety, permissions, testing, scheduling, logging, and overlap prevention. **[2 marks]**

> 📚 **Study first:** `set -euo pipefail`, `tar` (create/compress), `date +%F` for timestamps, `chmod 700` on scripts, `logger` or log redirection, `flock`, testing a script manually before scheduling it, `run-parts` / `grep CRON /var/log/syslog` to see cron activity.

---

## Case Study 1 — Nightly Backup Failure (10 marks)

At 02:00 every night, a server runs a home-directory backup. The script works when an engineer runs it manually, but the scheduled job produces no archive. The crontab contains a command using a relative executable name. The engineer also discovers that two long-running backup processes can exist at the same time.

**21.** Identify two likely causes from the case study and explain why they occur. **[3 marks]**

> 📚 **Study first:** Cron's environment and `PATH` (revisit Q19), why relative names fail, and what "overlapping jobs" means for a long-running process (revisit Q18).

**22.** Rewrite the cron entry using absolute paths, `flock`, and output/error logging. **[4 marks]**

> 📚 **Study first:** Combine what you learned in Q17 and Q18. Find real paths with `which tar`, `which flock`, `which bash`, and check them with `ls -l`.

**23.** Give two verification steps you would perform after changing the job. **[3 marks]**

> 📚 **Study first:** `crontab -l`, running the exact cron command by hand, `ls -lh` on the output archive, `tail` on the log file, `pgrep -a` / `ps aux | grep` to confirm there is only one run, and checking cron's own logs (`journalctl -u cron` or `/var/log/syslog`).

---

## Section E — systemd, Services & journalctl (15 marks)

**24.** Explain the difference between `start`, `stop`, `restart`, `reload`, `enable`, `enable --now`, and `disable`. **[3 marks]**

> 📚 **Study first:** `systemctl` subcommands. Key idea: *runtime state* (running now) vs. *boot-time state* (starts at boot). Also `systemctl is-enabled` and `systemctl is-active`.

**25.** A new application service file has been created under `/etc/systemd/system/api-service.service`. What must be done before systemd can use the new/changed unit? Give the commands. **[2 marks]**

> 📚 **Study first:** `systemctl daemon-reload`, then `systemctl enable --now`, and `systemctl status`. Understand why systemd caches unit files.

**26.** Why should a production application run under a dedicated unprivileged service account instead of root? Give the command pattern used in the handbook to create such an account. **[2 marks]**

> 📚 **Study first:** `useradd` (system-account flags `-r`, `-s /usr/sbin/nologin`, `-M` / `-d`), `adduser --system`, `id`, `getent passwd`. Think about blast radius if the app is compromised.

### Practical setup

Create `/var/www/api`, place these two files there, create a virtual environment if desired, install with `pip install -r requirements.txt`, then use the API with cURL. Do not submit the dependency installation output as the answer; submit your systemd configuration and verification evidence.

> 📚 **Study first:** `python3 -m venv`, `source venv/bin/activate`, `pip install -r`, `uvicorn main:app --host --port`, and `curl` against `/health`, `/`, and `/api/users`.

#### `requirements.txt`

```text
fastapi==0.115.6
uvicorn[standard]==0.34.0
pydantic==2.10.5
```

#### `main.py`

```python
from fastapi import FastAPI
from pydantic import BaseModel

app = FastAPI(title="Linux Engineer API")

class User(BaseModel):
    name: str
    role: str

@app.get("/health")
def health():
    return {"status": "ok"}

@app.get("/")
def root():
    return {"message": "Linux Engineering API is running"}

@app.post("/api/users")
def create_user(user: User):
    return {"created": True, "name": user.name, "role": user.role}
```

**Provided Python API Files for the Practical Questions**

**27.** Using the provided Python API files below, write a systemd unit for the API running from `/var/www/api` with uvicorn on port 8000. Include: User/Group, WorkingDirectory, Restart behavior, a restart delay, and at least three security/resource directives. **[5 marks]**

> 📚 **Study first:** The three unit sections `[Unit]`, `[Service]`, `[Install]`; `man systemd.service` and `man systemd.exec`. Directives to look up: `User=`, `Group=`, `WorkingDirectory=`, `ExecStart=` (absolute path to the venv's uvicorn), `Restart=`, `RestartSec=`, `NoNewPrivileges=`, `PrivateTmp=`, `ProtectSystem=`, `ProtectHome=`, `MemoryMax=`, `CPUQuota=`, `LimitNOFILE=`. Validate with `systemd-analyze verify` and `systemd-analyze security`.

**28.** Give `journalctl` commands to: follow live logs, view logs since the current boot, and display error-to-emergency priority messages only. **[2 marks]**

> 📚 **Study first:** `journalctl -f`, `-b`, `-p` (priority levels 0–7 and ranges like `a..b`), `-u <unit>`, `--since`, `-n`.

**29.** A service shows "failed". What commands would you use to inspect the unit, identify failed units generally, and inspect its journal? **[1 mark]**

> 📚 **Study first:** `systemctl status`, `systemctl --failed`, `systemctl cat <unit>`, `journalctl -u <unit>`, `systemctl reset-failed`.

---

## Case Study 2 — API Service Crash Loop (10 marks)

A production API starts successfully after deployment but crashes several times a minute. The service is configured with `Restart=always` and `RestartSec=5s`. Users see intermittent failures. The application engineer says the code is healthy, but the Linux engineer must establish what is actually happening before changing the application.

**30.** Describe your first five diagnostic steps using `systemctl`, `journalctl`, `ps`, `ss`, and cURL. State what evidence you are looking for. **[4 marks]**

> 📚 **Study first:** `systemctl status` (look at Active, Main PID, restart counter, exit code/signal), `journalctl -u ... -f`, `ps -o pid,etime,rss,cmd -p <pid>` (does the PID keep changing?), `ss -tlnp`, `curl -v`. Learn to read exit status vs. signal (e.g. `SIGKILL`).

**31.** Explain one benefit and one risk of `Restart=always` in this situation. **[2 marks]**

> 📚 **Study first:** `Restart=` options (`always`, `on-failure`, `on-abnormal`), `RestartSec=`, `StartLimitIntervalSec=` / `StartLimitBurst=`. Think about masking a real fault vs. recovering availability.

**32.** The server has a 1 GB memory limit configured for the service. What Linux/kernel evidence could help determine whether an OOM event killed the Python process? **[2 marks]**

> 📚 **Study first:** `dmesg -T | grep -i -E "oom|killed process"`, `journalctl -k`, `journalctl -u <unit>` (look for "oom-kill" / `Result: oom-kill`), `systemctl show -p MemoryMax,MemoryCurrent`, cgroup memory limits, `free -m`.

**33.** Propose two preventive improvements to the service configuration or monitoring. **[2 marks]**

> 📚 **Study first:** Resource directives in systemd (`MemoryMax=`, `MemoryHigh=`), restart rate limiting (`StartLimit*`), health checks (`curl /health` via a timer or monitoring tool), log retention, and alerting on service state.

---

## Section F — Production Diagnostics & Capacity (10 marks)

**34.** A filesystem reports plenty of free disk space, but an application cannot create new files. Which command from the handbook checks inode exhaustion? Explain the failure mechanism. **[2 marks]**

> 📚 **Study first:** `df -i` vs. `df -h`, what an inode is, and how millions of tiny files can exhaust inodes. Also `find <dir> -xdev -type f | wc -l` and `du --inodes`.

**35.** A server is experiencing slow disk-backed application performance. Which command should you run to investigate I/O saturation and wait time? Explain the key indicators you would inspect. **[2 marks]**

> 📚 **Study first:** `iostat -x 1` (from the `sysstat` package). Learn the columns `%util`, `await` (or `r_await`/`w_await`), `aqu-sz`, `%iowait`. Also `iotop` and `vmstat 1`.

**36.** An engineer suspects the Linux OOM subsystem terminated a daemon. Give the diagnostic command from the handbook and explain what it is looking for. **[2 marks]**

> 📚 **Study first:** `dmesg` (with `-T` and `grep`), `journalctl -k`, and what an OOM-killer log line contains (victim process, `oom_score`, memory stats).

**37.** Port 443 is expected to be reachable, but the application team says the firewall is blocking it. Show how you would distinguish between: no listener, local firewall issue, and network reachability issue. **[3 marks]**

> 📚 **Study first:** `ss -tlnp | grep :443` (listener), `ufw status verbose` / `iptables -L -n` (local firewall), `nc -zv host 443` and `curl -vk https://host` from another machine (network path), and how "connection refused" differs from "timed out".

**38.** Explain why `ss -tulpn` is preferred over `netstat` in the supplied handbook. **[1 mark]**

> 📚 **Study first:** `ss` vs. `netstat` (`net-tools` is deprecated, `iproute2` is modern), speed, and the meaning of each flag in `-tulpn`.

---

## Final Integrated Case Study — Production Deployment Incident (5 marks)

A company deploys a Python API to an Ubuntu server. After deployment, users report HTTP 500/connection errors. The engineer discovers that the API process is running intermittently, port 8000 is not always listening, disk usage is increasing, and a nightly backup sometimes overlaps with a previous run.

**39.** Build a complete incident-response plan in the correct order. Include at least eight commands from the supplied material and explain what each command checks. **[2 marks]**

> 📚 **Study first:** Order your plan like this: *scope → service state → logs → process → port → resources → firewall → app test*. Use `systemctl status`, `journalctl -u`, `ps aux`, `ss -tulpn`, `df -h` / `df -i`, `free -m`, `ufw status`, `curl`, `dmesg`, `du -sh` and `crontab -l`.

**40.** Propose a corrected systemd service design for the Python API, including least privilege, automatic restart, resource boundaries, security hardening, and journal-based diagnostics. **[1 mark]**

> 📚 **Study first:** Revisit Q26, Q27 and Q33 (user, restart policy, `MemoryMax`, hardening directives) and `StandardOutput=journal`.

**41.** Propose a corrected cron backup design that avoids overlap and preserves logs. **[1 mark]**

> 📚 **Study first:** Revisit Q18, Q20 and Q22 (`flock -n`, absolute paths, logging) and `logrotate` for log growth.

**42.** Give two long-term preventive controls that would reduce the chance of this incident recurring. **[1 mark]**

> 📚 **Study first:** Monitoring and alerting (disk, inode, memory, service state), `logrotate`, `journald` size limits (`SystemMaxUse`), staging deployments, and capacity/trend reviews.

---

## Practical Lab — Hands-on Linux Engineering (Recommended)

Complete the following in an Ubuntu/Debian VM. Submit terminal screenshots or command output.

**Lab 1:** Create `/opt/linux-lab/{scripts,logs,backups}`. Create a script, make it executable, and apply sensible ownership/permissions.

> 📚 **Study first:** `mkdir -p` with brace expansion, `touch`/`cat >`, `chmod`, `chown`, `ls -lR`.

**Lab 2:** Install nginx and verify the binary/package installation. Check its service state and listening port.

> 📚 **Study first:** `apt-get install`, `dpkg -l`, `dpkg -L`, `which nginx`, `nginx -v`, `systemctl status`, `ss -tlnp`.

**Lab 3:** Configure UFW to permit SSH and web traffic. Verify the resulting rules.

> 📚 **Study first:** `ufw allow` (SSH first!), `ufw enable`, `ufw status numbered` / `verbose`, `ufw delete`.

**Lab 4:** Create a backup script using `set -eo pipefail`, absolute paths, a timestamped archive, and a log file. Schedule it with cron and flock.

> 📚 **Study first:** `set -eo pipefail`, `date +%F_%H%M`, `tar -czf`, `>>` logging, `crontab -e`, `flock -n`.

**Lab 5:** Create an `api-service.service` for a simple Python HTTP/API process. Run it as an unprivileged user, enable it, and inspect its journal.

> 📚 **Study first:** `useradd -r`, writing unit files, `systemctl daemon-reload`, `enable --now`, `journalctl -u`.

**Lab 6:** Simulate a troubleshooting incident: stop the service, verify the missing listener with `ss`, test localhost with cURL, inspect systemd status/journal, and restore service.

> 📚 **Study first:** `systemctl stop/start`, `ss -tlnp`, `curl -v localhost:8000/health` (observe "connection refused"), `systemctl status`, `journalctl -u`.

**Lab 7:** Run `df -h` and `df -i` and explain the difference between storage capacity and inode capacity.

> 📚 **Study first:** Same as Q34: `df -h`, `df -i`, and what an inode stores (metadata, not data).

---

## Marking Rubric

| Area | Marks | What is assessed | Strong answer |
| --- | --- | --- | --- |
| Linux fundamentals & permissions | 20 | Commands, ownership, permissions, safe file operations | Correct command + clear operational reasoning |
| Monitoring & networking | 20 | Process/port/firewall/cURL troubleshooting | Evidence-driven diagnosis rather than guessing |
| Package management | 15 | Reliable installation and container hygiene | Correct sequence and CI/CD awareness |
| Cron automation | 15 | Scheduling, environment, logs, locking | Reliable automation with overlap protection |
| systemd & logs | 20 | Unit design, lifecycle, security, journalctl | Production-ready service design |
| Diagnostics & incident response | 10 | inode/OOM/I/O and integrated troubleshooting | Prioritized root-cause workflow |

## Instructor Notes / Expected Engineering Mindset

- Prefer diagnosis backed by command output over assumptions.
- Use least privilege for application services.
- Treat logs as operational evidence and retain stdout/stderr from scheduled jobs.
- Remember that cron has a minimal environment and may not load interactive shell configuration.
- Prevent overlapping automation when jobs can consume significant resources.
- When debugging network issues, separate process state, listening-port state, firewall policy, and endpoint response.
- For production services, combine lifecycle management with restart policy, security hardening, and resource boundaries.

**End of Assignment**
