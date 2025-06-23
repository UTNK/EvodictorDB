# Flask on SHIROKANE via FastCGI – Deployment Notes

## 🧩 Overview

Since SHIROKANE's web server does not support `mod_wsgi`, Flask applications must be deployed using **Apache + FastCGI + flup + Flask**.

The request flow works as follows:

1. Apache receives the request from the browser  
2. Apache executes a `.fcgi` script  
3. The `.fcgi` script launches `run_fcgi.py`  
4. `run_fcgi.py` starts the Flask app (`app.py`) as a FastCGI server  
5. Rendered HTML is returned to the browser

---

## 📁 Directory Structure (Project Example: `minimal`)

```
/usr/proj/evodictordb/
├── minimal/                  ← Flask app source
│   ├── app.py
│   ├── run_fcgi.py
│   └── templates/
│       └── index.html
├── cgi-bin/
│   └── minimal.fcgi           ← FastCGI entry script
├── htdocs/
│   └── .htaccess              ← Apache configuration
```

---

## ⚙️ Key Files and Their Roles

| File                     | Role                                       | Relative Path                             |
|--------------------------|--------------------------------------------|--------------------------------------------|
| `.htaccess`              | Enables `.fcgi` execution                  | `htdocs/.htaccess`                         |
| `minimal.fcgi`           | Bash script to launch Flask app            | `cgi-bin/minimal.fcgi`                     |
| `run_fcgi.py`            | Runs `WSGIServer(app).run()`               | `minimal/run_fcgi.py`                      |
| `app.py`                 | Flask application source                   | `minimal/app.py`                           |
| `index.html`             | HTML template for rendering                | `minimal/templates/index.html`             |

---

## 🚀 Example URL

The deployed app is accessible at:

```
https://evodictordb.hgc.jp/cgi-bin/minimal.fcgi
```

---

## 🔄 Restart Script (e.g., `safe_kill_fcgi.sh`)

Since Apache automatically regenerates processes, you can safely restart the app by running:

```
kill → then manually trigger .fcgi
```

### Example Location:

```
/usr/proj/evodictordb/scripts/safe_kill_fcgi.sh
```

---

## 🔐 Restricting Access (Optional)

To restrict access to a specific IP, add the following to `.htaccess`:

```
Order deny,allow
Deny from all
Allow from 123.45.67.89
```

---

## 🧪 Troubleshooting

| Symptom                                | Cause or Fix                                      |
|----------------------------------------|---------------------------------------------------|
| `.fcgi` script is shown as text        | Check `.htaccess` and file permissions            |
| `Internal Server Error`                | Check `flask_debug.log` and Apache error logs     |
| Template changes not reflected         | Old Flask process still running; needs restart    |
| `kill` doesn't stop process            | Apache auto-respawns; ensure correct restart flow |

---

## 📦 Adding a New Project (e.g., `project_2`)

1. Create `/usr/proj/evodictordb/project_2/` and place your Flask app there  
2. Add a new `project_2.fcgi` in `cgi-bin/` (copy from `minimal`)  
3. Update paths in `run_fcgi.py` accordingly  
4. Grant execution permission: `chmod +x`  
5. Public URL will look like:

```
https://evodictordb.hgc.jp/cgi-bin/project_2.fcgi
```

---

## 📂 Log Locations

| Type            | Example Path                                             |
|------------------|----------------------------------------------------------|
| Flask Logs       | `/tmp/minimal_fcgi.log` or `/tmp/projectname_fcgi.log`  |
| Apache Error Log | `/usr/local/package/apache/logs/evodictordb_error_log`  |

---

## ✅ Example Command to Check Running State

```bash
ps aux | grep run_fcgi.py
```

---

## 📝 Notes

- You need the `flup` package (`pip install flup`)
- `.fcgi` scripts **will not work if executed directly**; must be triggered via Apache
- Make sure to set Apache's `ExecCGI` and `chmod +x` as needed

---

## 🎯 Next Steps

- No need for `systemd`—Apache handles process management
- Manage multiple projects by separating `.fcgi` scripts under `cgi-bin/`
- A simple shell script to regularly restart `.fcgi` is useful for maintenance

---

This is the FastCGI deployment architecture for Flask on SHIROKANE.  
Always check `/tmp/*.log` and Apache error logs for troubleshooting.

Happy coding! 🚀
