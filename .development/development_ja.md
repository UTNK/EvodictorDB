# Flask on SHIROKANE via FastCGI – Deployment Notes

## 🧩 Overview

SHIROKANE の Web サーバでは `mod_wsgi` が使えないため、**Apache + FastCGI + flup + Flask** の構成でアプリケーションを公開する必要があります。

この構成では、以下の流れでリクエストが処理されます：

1. ブラウザからのリクエストを Apache が受け取る  
2. Apache は `.fcgi` スクリプトを実行  
3. `.fcgi` スクリプトが `run_fcgi.py` を起動  
4. `run_fcgi.py` 内で Flask アプリ（`app.py`）を FastCGI サーバとして起動  
5. レンダリングされた HTML がブラウザに返される

---

## 📁 ディレクトリ構成（プロジェクト1例: `minimal`）

```
/usr/proj/evodictordb/
├── minimal/                  ← Flask アプリ本体
│   ├── app.py
│   ├── run_fcgi.py
│   └── templates/
│       └── index.html
├── cgi-bin/
│   └── minimal.fcgi           ← FastCGI エントリスクリプト
├── htdocs/
│   └── .htaccess              ← Apache 向けの設定ファイル
```

---

## ⚙️ 重要ファイルの役割と配置

| ファイル                     | 役割                                       | 相対パス                                       |
|-----------------------------|--------------------------------------------|------------------------------------------------|
| `.htaccess`                 | `.fcgi` を実行可能に設定                   | `htdocs/.htaccess`                             |
| `minimal.fcgi`             | Flask アプリを起動する Bash スクリプト     | `cgi-bin/minimal.fcgi`                         |
| `run_fcgi.py`              | `WSGIServer(app).run()` を実行              | `minimal/run_fcgi.py`                        |
| `app.py`                   | Flask アプリ本体                            | `minimal/app.py`                             |
| `index.html`               | 表示するテンプレート                        | `minimal/templates/index.html`               |

---

## 🚀 URL 例

公開されたアプリは以下のような URL でアクセス可能：

```
https://evodictordb.hgc.jp/cgi-bin/minimal.fcgi
```

---

## 🔄 再起動用スクリプト（例：`safe_kill_fcgi.sh`）

プロセスが Apache により再生成されるため、**`kill` → `.fcgi` 実行**によりアプリを安全に再起動します。

### 設置場所例：

```
/usr/proj/evodictordb/scripts/safe_kill_fcgi.sh
```

---

## 🔐 アクセス制限の設定（必要に応じて）

`.htaccess` に以下を追記することで、特定の IP からのみアクセス可能にできます：

```
Order deny,allow
Deny from all
Allow from 123.45.67.89
```

---

## 🧪 トラブルシューティング

| 症状                                   | 原因または対処                                        |
|----------------------------------------|--------------------------------------------------------|
| `.fcgi` の中身が表示される             | `.htaccess` やパーミッションが不正                     |
| `Internal Server Error`                | `flask_debug.log` や Apache エラーログを確認           |
| HTML テンプレートの更新が反映されない | 古い Flask プロセスが動いている。再起動が必要         |
| `kill` してもプロセスが復活する       | Apache が自動で再生成。正しく `.fcgi` を再実行する    |

---

## 📦 新しいプロジェクト (仮名: `project_2`) の追加手順

1. `/usr/proj/evodictordb/project_2/` を作成し、Flask 構成を配置
2. `cgi-bin/` に `project_2.fcgi` を新規作成（中身は minimal を流用）
3. パスなどを `run_fcgi.py` 内で適切に修正
4. `.fcgi` に実行権限を付与 (`chmod +x`)
5. 公開 URL は以下のようになる：

```
https://evodictordb.hgc.jp/cgi-bin/project_2.fcgi
```

---

## 📂 ログ確認先

| ログ種別          | パス例                                                       |
|-------------------|--------------------------------------------------------------|
| Flask ログ        | `/tmp/minimal_fcgi.log` または `/tmp/projectname_fcgi.log` |
| Apache エラーログ | `/usr/local/package/apache/logs/evodictordb_error_log`      |

---

## ✅ 状態確認コマンド例

```bash
ps aux | grep run_fcgi.py
```

---

## 📝 備考

- `flup` パッケージが必要です（`pip install flup`）
- `.fcgi` スクリプトは **直接実行しても失敗する**（Apache 経由でのみ正しく動作）
- Apache の `ExecCGI` オプションや実行権限 (`chmod +x`) に注意

---

## 🎯 今後の展開

- `systemd` 等でプロセス監視は不要（Apache が自動生成）
- 複数プロジェクトの運用は `cgi-bin/` に `.fcgi` を分けて管理
- 定期的に `.fcgi` を再起動するシェルスクリプトは保守に便利

---

以上が、SHIROKANE における Flask アプリの FastCGI デプロイ構成です。  
トラブル時は `/tmp/*.log` や Apache エラーログを第一に確認してください。

Happy coding! 🚀
