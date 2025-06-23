# ✅ SHIROKANE FastCGI + Flask デプロイチェックリスト

このドキュメントは、SHIROKANE 環境で Apache + FastCGI + Flask を用いたアプリケーションを完全にデプロイするためのステップをまとめたものです。現在、IPアドレスによるアクセス制限は保留としています。

---

## 1. ✅ 確認済みの構成

- [x] `.fcgi` 経由で FastCGI が動作している
- [x] Flask アプリが `index.html` や `/vis` を正しく返す
- [x] クライアントIPが `/tmp/project_ip.log` に記録されている
- [x] ディレクトリとファイルのパーミッションが適切

---

## 2. 📁 ディレクトリ構成（例）

```
/usr/proj/evodictordb/
├── flask_app/                 # Flaskアプリケーション本体
│   ├── app.py
│   ├── run_fcgi.py
│   └── templates/
│       ├── index.html
│       └── taxonium.html
├── cgi-bin/
│   ├── minimal.fcgi
│   └── TaxoniumPhylomap.fcgi
├── htdocs/
│   └── .htaccess              # ExecCGI設定
├── scripts/
│   └── safe_kill_fcgi.sh     # 任意の再起動スクリプト
└── data/                     # データファイル
```

---

## 3. 🔁 プロセス再起動の手順

FastCGIプロセスを手動で再起動するには：

```bash
ps aux | grep run_fcgi.py
kill <プロセスID>
```

Apacheが自動で新しいプロセスを生成します。

オプション：以下のスクリプトを使う

```bash
/usr/proj/evodictordb/scripts/safe_kill_fcgi.sh
```

---

## 4. 🔒 アクセス制限（保留中）

以下の方法のいずれかでアクセス制限可能：

- `.htaccess` に `Require ip` を記述（パーミッション要注意）
- Flask 内で `@app.before_request` による制御

現在はパーミッション関連の問題があり、制限は無効化中です。

---

## 5. 🔍 ログの確認場所

| ログ種別         | パス例                                                 |
|------------------|--------------------------------------------------------|
| Flaskログ         | `/tmp/project_ip.log`                                 |
| Apacheエラーログ | `/usr/local/package/apache/logs/evodictordb_error_log` |

---

## 6. 🧪 テスト項目

- [ ] 複数のデバイスからアクセス確認
- [ ] `/`, `/vis` 各URLの動作確認
- [ ] 無効なURL時のエラー応答確認
- [ ] データ読み込みが重いときの挙動確認
- [ ] `kill`→自動再起動の挙動確認

---

## 7. 🔐 デプロイ直前の最終チェック

- [ ] アクセス制限（必要であれば有効化）
- [ ] `print()`や一時ログの削除
- [ ] パーミッションの再確認（グループ書き込み不可が理想）
- [ ] `.fcgi` や `.py` のバックアップ
- [ ] GitHub（非公開）にプッシュ

---

## 🚀 Git によるバージョン管理

`/usr/proj/evodictordb` をGitで管理するには：

```bash
cd /usr/proj/evodictordb
git init
echo "TaxoniumPhylomap/" >> .gitignore
git add .
git commit -m "Initial commit for deployment"
git remote add origin git@github.com:<ユーザー名>/<リポジトリ>.git
git push -u origin main
```

---

## 📝 備考

- `flup` パッケージが必要（`pip install flup`）
- `.fcgi` スクリプトは直接実行しても動作しない（Apache 経由のみ）
- `.htaccess` の権限と `ExecCGI` の指定を忘れずに

---

## 🎯 今後の展望

- `systemd` 等の監視は不要（Apacheが再起動）
- プロジェクトごとに `.fcgi` を分けて運用可能
- `safe_kill_fcgi.sh` などでメンテ性向上

---

以上が、SHIROKANE 環境で Flask を FastCGI 経由でデプロイするための要点です。  
何か問題が発生した場合は、まず `/tmp/*.log` や Apache のログを確認しましょう。

Happy deploying! 🚀
