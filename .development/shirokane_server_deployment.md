
# SHIROKANEにおけるサーバー保守・運用手順書（Blue-Green Deployment方式）

## 概要

本手順書は、SHIROKANEでFlask+FastCGIアプリケーションなどのWebサービスを運用する際、Blue-Greenデプロイメント方式に基づいて安全かつダウンタイムゼロで更新・保守するための運用フローを示します。

---

## 🔧 ディレクトリ構成

```
~/evodictordb/
├── blue/                     # 現在本番稼働中の環境
│   └── EvodictorDB-AMR.fcgi
├── green/                    # 新バージョン検証用の環境
│   └── EvodictorDB-AMR.fcgi
├── cgi-bin → blue/           # 本番用のシンボリックリンク（切り替えポイント）
├── htdocs/
│   └── green-test/           # 一時的に確認したい場合の公開URL用
```

---

## 🧪 Green環境の検証方法

### 方法A：ローカル（非公開）での検証

```bash
cd ~/evodictordb/green
export FLASK_APP=app.py
flask run --host=127.0.0.1 --port=8000
```

- `curl http://127.0.0.1:8000/` で動作確認
- 外部には公開されない安全な検証環境

### 方法B：一時的パスでの確認（公開URLあり）

- Green環境の.fcgiを `~/htdocs/green-test/` 以下にコピー：

```bash
mkdir -p ~/htdocs/green-test/
cp ~/evodictordb/green/EvodictorDB-AMR.fcgi ~/htdocs/green-test/
```

- 公開URL: `https://evodictordb.hgc.jp/~<username>/green-test/EvodictorDB-AMR.fcgi`

### 方法C：擬似IP制限（Pythonアプリ内）

```python
from flask import request, abort
if request.remote_addr not in ['127.0.0.1', '133.11.xxx.xxx']:
    abort(403)
```

---

## 🚀 本番切り替え手順（Blue → Green）

```bash
# シンボリックリンクをgreenに切り替え
ln -sfn ~/evodictordb/green ~/evodictordb/cgi-bin
```

- Apacheは `~/cgi-bin/` を参照しているので、即座に新バージョンが有効化される
- 公開URLは変更されない（例：`https://evodictordb.hgc.jp/cgi-bin/EvodictorDB-AMR.fcgi`）

---

## 🔁 ロールバック手順（Green → Blue）

```bash
# シンボリックリンクをblueに戻す
ln -sfn ~/evodictordb/blue ~/evodictordb/cgi-bin
```

---

## 🔄 更新運用のサイクル

1. green/ にコード・データ更新
2. ローカルや一時公開で検証（curl, ブラウザ, log）
3. 問題なければ `cgi-bin` のリンクをgreenに切り替え
4. ログを確認し安定稼働を確認
5. blue/ をgreenと同期し、次回更新に備える

---

## 📎 注意点

- `.htaccess` は無効なためIP制限はFlaskなどアプリ側で実装する
- 公開パスは変更しないことを推奨（ユーザーにとっての安定性）
- `/home/<user>/htdocs/` 以下は自由に公開できるが、機密情報の公開に注意

---

## 📘 補足：検証スクリプト例

### `test_green.sh`

```bash
#!/bin/bash
cd ~/evodictordb/green
export FLASK_APP=app.py
flask run --host=127.0.0.1 --port=8000
```

---

## お問い合わせ先

- 管理者: konnonaoki（ユーザー名）
- URL: https://evodictordb.hgc.jp/
