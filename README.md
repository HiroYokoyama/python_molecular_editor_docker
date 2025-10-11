# mMoleditPy for Docker

## 概要

このリポジトリは、GUIアプリケーション `moleditpy` をDockerコンテナ上で実行するための環境を構築する `Dockerfile` を提供します。

LinuxのGUIアプリケーションをDockerコンテナで動作させるには、ベースとなるOSイメージに含まれていない多数のグラフィックス、ウィンドウシステム、および入力関連のシステムライブラリが必要です。この `Dockerfile` は、`moleditpy` を安定して実行するために必要な依存関係をすべてインストールし、再現性の高い環境を作成します。

## 主な特徴

  * **Python 3.11** の実行環境
  * `moleditpy-linux` アプリケーションのインストール
  * GUIアプリケーションの実行に不可欠なシステムライブラリ群：
      * **グラフィックス関連:** OpenGL, Mesa, EGL (`libgl1`, `libglu1-mesa`, `libegl1` など) 
      * **X11/XCB関連:** ウィンドウ管理、キーボード・マウス入力、ディスプレイ通信 (`libx11-xcb1`, `libxkbcommon-x11-0`, 多数の `libxcb-*` ライブラリなど)
      * **コアライブラリ:** フォント設定やイベントループ (`libfontconfig1`, `libglib2.0-0` など) 

## 前提条件

  * [Docker](https://www.docker.com/get-started) がインストールされていること。
  * **Linux:** 標準のデスクトップ環境。
  * **macOS:** [XQuartz](https://www.xquartz.org/) がインストール・設定されていること。
  * **Windows:** [VcXsrv](https://sourceforge.net/projects/vcxsrv/) や、WSL2のGUIサポート (WSLg) が有効であること。

## 使い方

### 1\. リポジトリをクローン

```bash
git clone https://github.com/HiroYokoyama/python_molecular_editor_docker
cd moleditpy-app
```

### 2\. Dockerイメージをビルド

`Dockerfile` があるディレクトリで、以下のコマンドを実行して `moleditpy-app` という名前のDockerイメージをビルドします。

```bash
docker build -t moleditpy-app .
```

### 3\. コンテナを実行 (GUI表示)

コンテナ内のGUIをホストマシン（あなたのPC）の画面に表示するには、特別な設定が必要です。

#### Linuxホストの場合

1.  **（初回のみ）コンテナからの接続を許可**
    ホストのターミナルで以下のコマンドを実行します。

    ```bash
    xhost +local:docker
    ```

2.  **コンテナを起動**
    以下のコマンドでコンテナを起動すると、`moleditpy` のGUIウィンドウがデスクトップに表示されます。

    ```bash
    docker run --rm -it \
           -e DISPLAY=$DISPLAY \
           -v /tmp/.X11-unix:/tmp/.X11-unix \
           moleditpy-app
    ```

#### macOS / Windows の場合

基本的なコマンドは同じですが、環境変数 `DISPLAY` の設定が異なる場合があります。（例: `docker.for.mac.host.internal:0` など）

-----

*This Dockerfile was constructed through an iterative debugging process, ensuring that all necessary dependencies for the Qt-based GUI application are included.*
