---
tags:
  - SQL
  - Linux
title: Fedora安裝Sql
created: 2025-07-28T08:57:32
modified: 2025-07-28T12:43:55
---

# 安裝MySql

`$(rpm -E %fedora)` 會自動替換成你的 Fedora 版本。
```shell
sudo dnf install https://dev.mysql.com/get/mysql80-community-release-fc$(rpm -E %fedora)-1.noarch.rpm
```

後來發現Mysql沒有Fedora42版本

## 可以安裝上一版41

```bash
sudo dnf install https://dev.mysql.com/get/mysql80-community-release-fc41-1.noarch.rpm
sudo dnf install mysql-community-server
```
但dnf update
-  會升級你目前 repo 綁定的版本（例如 `8.0.36 → 8.0.37`）。
- **不會升級到 `8.1` 或 `9.0`**，除非你手動更換 repo。
- 官方會維持 `mysql80-community.repo`、`mysql81-community.repo`、`mysql57-community.repo` 等彼此獨立。

## 安裝SQL各版本更新規則

|安裝來源|`dnf update` 是否會自動升級版本|備註|
|---|---|---|
|Fedora 官方套件庫（MariaDB）|✅ **會自動升級次版本（如 10.5 → 10.6）**|依據 Fedora 當前支援版本進行滾動升級|
|MySQL 官方 repo (`mysql80-community-release`)|⚠️ **只升小版本（如 8.0.36 → 8.0.37）**，不會升級大版本（如 8.0 → 8.1）除非 repo 換成 `mysql81-community-release`|Oracle 的 repo 預設綁定某個主版本線|
|手動安裝 `.rpm`|❌ 不會自動升級|沒 repo metadata|
|Docker container|❌ 主機升級不影響容器|要你自己 `docker pull` 升級|


# 為什麼 Fedora 官方只支援 MariaDB？

- Fedora 是 Red Hat 支系，Red Hat 決定全面轉向使用 MariaDB（避免 Oracle 授權問題）。
-  `dnf install mysql-server` 時實際上裝的是 `mariadb-server`。
- 如果安裝 `mysql-community-server`，那就是來自 Oracle 的 repo，需要手動維護。

# MariaDB vs MySQL 差異一覽

|面向|MySQL (Oracle)|MariaDB (社群版)|
|---|---|---|
| 開發主導|Oracle|MariaDB Foundation|
| 功能相容|完全相容（前期）|基本相容，但功能愈來愈多樣|
|授權|開源 + 專有部分|完全 GPL|
| JSON 支援|✅ (原生 JSON type)|✅（但實作不同）|
| 複製功能|InnoDB Replication|多種複製（包括 Galera）|
| 新功能更新頻率|較保守（穩定）|積極開發（但有可能不穩）|
| 最終趨勢|商業導向（企業支持）|社群導向（Fedora、Debian 都改用）|


# 安裝MariaDB

```bash
sudo dnf install mariadb-server
sudo systemctl enable --now mariadb
sudo mysql_secure_installation
```

## MariaDB Server（官方社群版）

- `mariadb-server`（資料庫核心）
- 所需的 systemd 服務、socket 等

## 啟動並設為開機自動啟動

```bash
sudo systemctl enable --now mariadb
```

## 進行安全性初始化

```bash
sudo mysql_secure_installation
```


- Switch to unix_socket authentication [Y/n]
	- `unix_socket` 認證方式就是**透過 Linux 系統帳號來驗證 MariaDB 使用者身份**，不需要密碼。
	- 讓 **`mysql -u root` 不需要輸入密碼**，只要你是用系統的 `root` 或 `sudo` 使用者登入，系統就會自動讓你以 root 權限登入 MariaDB
	- y 可以輸入sudo mysql，直接登入
- Change the root password? [Y/n]
	- unix_socket 為 y 時 不能change

- 查帳號用的是哪種驗證
```sql
SELECT user, host, plugin FROM mysql.user WHERE user='root';
```

```shell
#系統帳號登入
root | localhost | unix_socket
#傳統輸入密碼
root | localhost | mysql_native_password
```

# 建立新的帳號給程式用
```sql
CREATE USER 'appuser'@'localhost' IDENTIFIED BY 'yourpassword';
GRANT ALL PRIVILEGES ON your_database.* TO 'appuser'@'localhost';
FLUSH PRIVILEGES;

```

# SQL的GUI

用flatpak安裝
```bash
#install
flatpak install flathub io.dbeaver.DBeaverCommunity
#run
flatpak run io.dbeaver.DBeaverCommunity

```