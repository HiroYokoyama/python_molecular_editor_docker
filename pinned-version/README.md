# README - Pinned Version for Reproducible Builds

このドキュメントは、依存関係のバージョンを完全に固定（ピニング）した `moleditpy-app` の `Dockerfile` について解説します。

このアプローチを採用することで、\*\*「いつでも、誰が、どこでビルドしても、全く同じ環境が構築されること」\*\*を保証します。

## 1\. バージョン固定（Pinning）とは？

バージョン固定とは、アプリケーションが依存する全てのソフトウェア（ベースイメージ、OSパッケージ、Pythonライブラリなど）のバージョンを、特定の一つに明確に指定することです。

例えば、「`libgl1` をインストールする」という曖昧な指示ではなく、「`libgl1` のバージョン `1.7.0-1+b2` を正確にインストールする」と厳密に指示します。

### なぜバージョンを固定するのか？

1.  **絶対的な再現性 (Absolute Reproducibility)**
    開発、テスト、本番環境で寸分違わぬ同一の環境を保証します。「私のPCでは動いたのに…」という問題を完全に撲滅します。

2.  **安定性の確保 (Stability)**
    依存パッケージのマイナーアップデートによって、意図せずアプリケーションが動かなくなる「サイレントな破壊」を防ぎます。今日動くビルドは、1年後も同じように動きます。

3.  **デバッグの容易化 (Easier Debugging)**
    環境が不変であるため、問題が発生した際に原因が依存関係の更新にある可能性を排除でき、アプリケーション自体のコードに集中してデバッグできます。

## 2\. このDockerfileにおける実装

このプロジェクトでは、以下の3つのレベルでバージョンを固定しています。

### a) ベースイメージ (Base Image Digest)

[cite\_start]`Dockerfile`の最初の行で、ベースイメージをタグ (`3.11-slim`) だけでなく、**ダイジェスト (`@sha256:...`)** で指定しています [cite: 1]。

```dockerfile
[cite_start]FROM python:3.11-slim@sha256:5e9093a415c674b51e705d42dde4dd6aad8c132dab6ca3e81ecd5cbbe3689bd2 [cite: 1]
```

  * **タグ**は移動可能なラベルであり、時間と共に新しいイメージを指す可能性があります。
  * **ダイジェスト**はイメージの「指紋」であり、イメージの内容と1対1で対応します。これにより、ベースとなるOS環境が未来永劫変わらないことを保証します。

### b) OSパッケージ (apt)

[cite\_start]`RUN apt-get install` コマンドでインストールする全てのライブラリについて、`パッケージ名=バージョン` の形式で正確なバージョンを指定しています [cite: 1, 2]。

```dockerfile
RUN apt-get update && apt-get install -y --no-install-recommends \
    libxcb-cursor0=0.1.5-1 \
    libgl1=1.7.0-1+b2 \
    ...
    libglib2.0-0t64=2.84.4-3~deb13u1 \
    && rm -rf /var/lib/apt/lists/*
```

[cite\_start]これらのバージョンは、`apt-cache policy <パッケージ名>` コマンドを使ってベースイメージ内で特定されたものです。`t64` のようなサフィックスも、システムのアーキテクチャに合わせた厳密な指定です [cite: 2]。

### c) Pythonパッケージ (pip)

[cite\_start]Pythonの依存関係は `requirements.txt` ファイルで管理されます。`pip install` コマンドはこのファイルを参照して、指定されたバージョンのパッケージをインストールします [cite: 3]。

```dockerfile
[cite_start]COPY requirements.txt . [cite: 2]
RUN pip install --no-cache-dir --upgrade pip && \
    [cite_start]pip install --no-cache-dir -r requirements.txt [cite: 3]
```

`requirements.txt` は通常、`pip freeze` コマンドで生成され、`moleditpy` 本体だけでなく、`PyQt6` などの間接的な依存関係もすべてバージョン固定でリストアップします。

```txt
# requirements.txt の例
moleditpy-linux==1.2.6.2
PyQt6==6.9.1
...
```

## 3\. 使い方

ビルドと実行の方法は通常版と同じですが、この`Dockerfile`を使うことで、常に同じ結果が得られます。

1.  **Dockerイメージをビルドする**

    ```bash
    docker build -t moleditpy-app:pinned .
    ```

2.  **コンテナを実行する (Linuxの場合)**

    ```bash
    xhost +local:docker
    docker run --rm -it \
           -e DISPLAY=$DISPLAY \
           -v /tmp/.X11-unix:/tmp/.X11-unix \
           moleditpy-app:pinned
    ```

## 4\. メンテナンス：依存関係の更新方法

バージョンを固定すると、セキュリティアップデートなどが自動で適用されなくなるため、**意図的かつ定期的なメンテナンス**が必要になります。

1.  **ベースイメージの更新:**

      * `docker pull python:3.11-slim` を実行して最新版を取得します。
      * `docker images --digests python:3.11-slim` で新しいダイジェストを調べ、`Dockerfile`の`FROM`行を更新します。

2.  **OSパッケージの更新:**

      * 新しいベースイメージのコンテナを起動し、`apt-cache policy` で各パッケージの最新バージョンを調べ、`Dockerfile`を更新します。

3.  **Pythonパッケージの更新:**

      * クリーンなPython仮想環境で `pip install --upgrade moleditpy-linux` を実行します。
      * `pip freeze > requirements.txt` を実行して、`requirements.txt` ファイルを再生成します。

更新後は、アプリケーションが正しく動作するかを十分にテストしてください。
