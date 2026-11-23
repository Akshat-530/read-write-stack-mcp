<div align="center">

# 📂 Read-Write-Stack MCP

### 🔓 **One MCP server. Root access. Read & write anything — files, shell, Python, documents AND databases.** 🔓

**56 tools · filesystem + shell + Python + GenOffice + databases · root access**

[![repo](https://img.shields.io/badge/repo-public-2ea043?style=for-the-badge&logo=github)](#)
[![tools](https://img.shields.io/badge/tools-56-6f42c1?style=for-the-badge)](#-tool-coverage)
[![databases](https://img.shields.io/badge/databases-10%20sources-1f6feb?style=for-the-badge)](#-databases-read--write)
[![root](https://img.shields.io/badge/access-root%20%F0%9F%94%93-critical?style=for-the-badge)](#-root-access)
[![docker](https://img.shields.io/badge/ghcr.io-read--write--stack--mcp-2496ed?style=for-the-badge&logo=docker&logoColor=white)](#-quick-start)
[![license](https://img.shields.io/badge/license-MIT-2ea043?style=for-the-badge)](#-license)

<sub>Point your client at <b>one</b> endpoint — <code>http://127.0.0.1:4034/mcp</code> — and read, write, run, edit and query everything.</sub>

</div>

---

## 🚀 What is this?

Five MCP servers — a filesystem server, a shell server, a Python interpreter, a
document engine and a universal database gateway — **consolidated into one
container**, behind **one** MCP endpoint, running as **root**.

```text
       before                                 after
  ┌──────────────┐                      ┌───────────────────────────┐
  │ filesystem   │                      │        📂 Read-Write-Stack │
  │ shell        │   ───────►           │        one endpoint        │
  │ python       │                      │        :4034/mcp           │
  │ genoffice    │                      │        root · 56 tools     │
  │ databases    │                      └───────────────────────────┘
  └──────────────┘
```

An agent connected here can read and write **any file on your drives**, run
**any shell command**, execute **Python**, edit **Office documents** — and
**query or modify any database** you point it at. One connection, full power.

---

## 🗄️ Databases (read & write)

Powered by **SmartDB** — a universal gateway. **Connect any database by adding a
pool**; its tools register automatically, and with role **`admin`** you get
**full read + write** (DDL + DML).

| Type | Paradigm | Read | Write |
|---|---|---|---|
| `mysql` (MySQL 5.6+, MariaDB 10+) | relational | ✔ | ✔ `execute_sql` |
| `postgresql` (9.6+, YMatrix) | relational | ✔ | ✔ `execute_sql` |
| `oracle` (12+) | relational | ✔ | ✔ `execute_sql` |
| `mssqlserver` (SQL Server 2012+) | relational | ✔ | ✔ `execute_sql` |
| `redis` (5.0+) | KV | ✔ | ✔ `execute_command`, `scan_keys`, `get_key_info` |
| `mongodb` (4.0+) | document | ✔ | ✔ `execute_mongo_query` / `execute_mongo_write` |
| `milvus` (2.3+) | vector | ✔ | — (search only) |
| `elasticsearch` (7/8/9) | search | ✔ | — (query only) |
| `kafka` | message queue | ✔ | — (topic/offset/lag only) |

> Universal on every source: `get_db_health`, `get_db_version`.
> Relational extras: `get_table_desc`, `get_table_index`, `get_table_name`, `sql_creator`, `sql_optimize`.

### Connect your database — 2 steps

**1.** Put a pool in `database_config.json` (mounted at `/data/config/database_config.json`):

```json
{
  "default": {
    "host": "host.docker.internal",
    "port": 3306,
    "user": "root",
    "password": "your_password",
    "database": "your_database",
    "role": "admin",
    "pool_size": 10,
    "type": "mysql"
  },
  "redis": {
    "host": "host.docker.internal",
    "port": 6379,
    "user": "default",
    "password": "your_password",
    "database": "0",
    "db": 0,
    "role": "admin",
    "pool_size": 50,
    "type": "redis"
  }
}
```

> Keep at least one pool literally named **`default`** — SmartDB requires it at startup.

**2.** Reload: `docker restart read-write-stack`

Then ask your agent, e.g. *“run SELECT * FROM users LIMIT 10 on the default pool”*
or *“SET a key in redis”* — it just works.

### Roles

| role | MySQL / PostgreSQL / Oracle / SQL Server | Redis / MongoDB |
|---|---|---|
| `readonly` | SELECT / SHOW / DESCRIBE / EXPLAIN | reads only |
| `writer` | + INSERT / UPDATE / DELETE | + writes |
| `admin` | + CREATE / ALTER / DROP / TRUNCATE | full |

> **`admin` = full read/write (root-equivalent).** That's the shipped default.

### Verified

- ✅ Live-connected a **Redis 7.4.12** — `get_db_version` returned `Redis Version: 7.4.12`; `scan_keys`, `get_key_info`, `execute_command` exposed at `admin`.
- ✅ Pools load cleanly: `default, postgresql, oracle, mssql, redis`.

### Notes (from the build's own validator)

- **Every pool needs `user`, `password` and `database`** — even Redis (use `user: "default"`, `database: "0"`). Missing any → the pool is rejected.
- The pool loader is **all-or-nothing** — keep entries valid.
- **Milvus connects at startup** — point it at a live server (a placeholder will stop SmartDB).
- `host.docker.internal` reaches databases on your host; on Linux add `--add-host=host.docker.internal:host-gateway`.

---

## 🧰 Tool coverage — `56 tools`

| Upstream | What it adds | Tools |
|---|---|---|
| 🗂️ **filesystem** (official MCP) | read / write / edit / move / copy / search files, directory tree | `16` |
| 🐚 **shell** | `execute_command` (bash) as root | `1` |
| 🐍 **python** | run code / file, `pip install`, read/write files | `10` |
| 📄 **genoffice** | docx / xlsx / pptx / pdf read + byte-preserving edit | `15` |
| 🗄️ **SmartDB** | databases — SQL, Redis, Mongo, ... (see above) | `8` + `3` per Redis pool |
| 🔧 **stack helpers** | `rw_status` · `rw_refresh` · `rw_rotation` (reachability, config reload, key-rotation status) | `3` |

> The three helpers are served by the aggregator itself. Their prefix is
> configurable (`server.helperPrefix`, here `rw`).

---

## 🔓 Root access

The container runs as **root**. Host drives are **not** mounted by default —
mount them **read-write** yourself if you want that reach:

| Layer | Setting |
|---|---|
| 🗂️ filesystem | allowed directory = `/` |
| 🐍 python | `MCP_ALLOW_SYSTEM_ACCESS=1` |
| 🐚 shell | allowed `/`, runs as root |
| 📄 genoffice | no path restriction |
| 🗄️ SmartDB | `role: admin` = full DB read/write |
| 💾 mounts | only `./workspace` → `/work` (rw); host drives (`C:\`, `D:\`, …) are **opt-in** via `docker-compose.example.yml` |

> ⚠️ Anything you mount read-write is fully readable and writable by any connected
> agent. Only connect trusted agents, and prefer read-only (`:ro`) mounts.

---

## ⚡ Quick start

```bash
git clone https://github.com/Akshat-530/read-write-stack-mcp.git
cd read-write-stack-mcp

docker build -t read-write-stack:allinone .
docker run -d --name read-write-stack \
  -p 127.0.0.1:4034:4034 \
  -v "C:\:/host/c" -v "D:\:/host/d" \
  read-write-stack:allinone
```

Or with the published image:

```bash
docker compose -f docker-compose.example.yml up -d
```

Then connect your MCP client to **`http://127.0.0.1:4034/mcp`**.

---

## 🔗 Connect your MCP client

**Claude Desktop / Cursor** (`mcpServers`):

```json
{ "mcpServers": { "read-write-stack": { "type": "remote", "url": "http://127.0.0.1:4034/mcp" } } }
```

**Kilo** (`kilo.jsonc`):

```jsonc
{ "mcp": { "read-write-stack-mcp": { "type": "remote", "url": "http://127.0.0.1:4034/mcp", "enabled": true, "timeout": 1800000 } } }
```

Reload → **56 tools** appear. Sanity check: call **`rw_status`**.

---

## ⚙️ Configuration

| File | Purpose |
|---|---|
| `/data/config/config.json` | aggregator: which upstreams/tools are exposed |
| `/data/config/database_config.json` | database pools |
| `/data/config/smartdb.env` | SmartDB env (`DATABASE_CONFIG_FILE`, `SERVER_PORT`) |

The image is **self-contained** (all three are baked). Override by mounting your own:

```bash
-v ./my-config.json:/data/config/config.json:ro
-v ./my-databases.json:/data/config/database_config.json:ro
```

---

## 🛠️ Operations

```bash
docker exec read-write-stack supervisorctl status     # every upstream
docker logs -f read-write-stack
```

Supervised upstreams: `filesystem`, `shell`, `python`, `genoffice`, `smartdb`.

---

## 🩺 Troubleshooting

| Symptom | Fix |
|---|---|
| DB tools not appearing | pool entry invalid → check `rw_status` + `docker logs`; every pool needs `user`+`password`+`database` |
| A pool rejected at startup | fix its fields; the loader is all-or-nothing |
| Milvus stops the server | point it at a live Milvus, or remove that pool |
| SQL tool errors “can’t connect” | DB not reachable, or wrong credentials |
| `shell` / `python` upstream not OK | shell runs via an async launcher; check `supervisorctl status` |

---

## 📜 License

MIT — see [LICENSE](LICENSE).
Upstream MCP servers, GenOffice (Apache-2.0 engine) and SmartDB keep their own licenses.

<div align="center">
<sub>Built with 📂 by <a href="https://github.com/Akshat-530">Akshat-530</a></sub>
</div>
