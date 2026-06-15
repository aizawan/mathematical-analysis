# mathematical-analysis

数理解析の講義資料です．下記はサポートページの公開作業用です．実行する必要はありません．

## 環境構築

このリポジトリでは `uv` を使って Python 環境を作成します．PyTorch が Python 3.10 以上を要求するため，MacBook では Python 3.12 などを明示して仮想環境を作るのが安全です．

この教材は Jupyter Book 2 形式です．設定と目次は `myst.yml` にまとめています．

```bash
cd /Users/aizawa/workspace/mathematical-analysis

uv venv --python 3.12
uv pip install -r requirements.txt
```

`uv` が未導入の場合は，先にインストールしてください．

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

## Jupyter Notebook の起動

次のコマンドで Jupyter Notebook を起動します．

```bash
uv run jupyter notebook
```

必要に応じて，このプロジェクト用のカーネルを Jupyter に登録できます．

```bash
uv run python -m ipykernel install --user \
  --name mathematical-analysis \
  --display-name "Python (mathematical-analysis)"
```

Notebook 画面では，カーネルとして `Python (mathematical-analysis)` を選択してください．

## Google Colab で開く

各 Notebook の冒頭には，Google Colab で開くためのリンクを追加しています．リンク先は GitHub 上の `main` ブランチにある Notebook です．

```text
https://colab.research.google.com/github/aizawan/mathematical-analysis/blob/main/...
```

## Jupyter Book のビルド

実行結果付きの HTML をビルドするには，リポジトリ直下で次を実行します．

```bash
uv run jupyter book build --html --execute --execute-parallel 1
```

生成された HTML は次の場所に出力されます．

```text
_build/html/index.html
```

## ビルド済み HTML のローカル確認

Jupyter Book 2 の HTML は CSS や JavaScript を `/build/...` のような絶対パスで参照するため，`file://` で `index.html` を直接開くと白画面になることがあります．ローカル確認では，簡易 Web サーバーを起動してブラウザから開いてください．

```bash
uv run python -m http.server 8000 -d _build/html
```

ブラウザで次の URL を開きます．

```text
http://localhost:8000
```

ビルドからローカル確認用サーバーの起動までまとめて実行する場合は，次のスクリプトを使えます．

```bash
./scripts/build-local.sh
```

ポートを指定する場合は，次のように指定します．指定したポートが使用中の場合は，次の空きポートを自動で使います．

```bash
./scripts/build-local.sh 8001
```

Notebook を実行せず，保存済みの出力だけを使ってビルドする場合は，`--execute` を外します．

```bash
uv run jupyter book build --html
```

Jupyter Book 2 では，実行結果は `_build/execute` にキャッシュされます．すべて再実行したい場合は，実行キャッシュを削除してからビルドします．

```bash
uv run jupyter book clean --execute
uv run jupyter book build --html --execute --execute-parallel 1
```

ビルドが途中で進まない場合は，まず逐次実行でどの Notebook で止まっているかを確認します．

```bash
uv run jupyter book clean --execute
uv run jupyter book build --html --execute --execute-parallel 1
```

`--execute-parallel 1` を付けると Notebook を1つずつ実行するため，ログ上で止まっているファイルを特定しやすくなります．問題のある Notebook を Jupyter Notebook で直接開き，`Restart Kernel and Run All Cells` で同じ箇所が止まるか確認してください．

## Jupyter Book の公開

GitHub Pages に手動で公開する場合は，`ghp-import` を使ってビルド済み HTML を `gh-pages` ブランチへ反映します．

```bash
uv run jupyter book build --html --execute --execute-parallel 1
uv run ghp-import -n -p -f _build/html
```

`ghp-import` は `requirements.txt` に含めています．個別にインストールしてから実行する場合は，次のようにします．

```bash
uv pip install ghp-import
uv run ghp-import -n -p -f _build/html
```

各オプションの意味は次の通りです．

- `-n`: `.nojekyll` を追加し，GitHub Pages 側の Jekyll 処理を無効化します．
- `-p`: 生成した `gh-pages` ブランチを GitHub に push します．
- `-f`: 既存の `gh-pages` ブランチを上書きします．

初回公開時は，GitHub の repository settings で Pages の公開元を確認してください．`ghp-import` を使う場合は，通常 `gh-pages` ブランチを公開元にします．

継続的に公開する場合は，GitHub Actions で `jupyter book build --html --execute --execute-parallel 1` を実行し，`_build/html` を GitHub Pages に deploy する方法もあります．手元の MacBook から必要なときだけ公開する場合は，`ghp-import` で十分です．

## PyTorch について

MacBook で Jupyter Book をビルドするだけであれば，通常は次のインストールで問題ありません．

```bash
uv pip install torch
```
