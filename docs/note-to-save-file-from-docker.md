# Docker版 Python Molecular Editor: ファイルをホストPCに保存するためのバインドマウント設定ガイド
このドキュメントは、Dockerコンテナとして実行する「Python Molecular Editor」で作成したファイルを、ホストPC上の指定フォルダに永続的に保存するための技術的な手順を解説します。
1. 目的
Dockerコンテナは、デフォルトではステートレス（状態を持たない）です。コンテナ内でGUIアプリケーションを使いファイルを作成しても、コンテナを削除 (docker rm) するとそのファイルは失われます。
この問題を解決するため、ホストPCのフォルダをコンテナ内の特定のフォルダに直接接続（バインドマウント）します。これにより、コンテナ内のアプリケーションから見ると通常のフォルダとしてファイルを保存でき、その実体はホストPC上に永続的に保管されます。
2. 前提条件
 * DockerがホストPCにインストールされていること。
 * （重要）GUIアプリケーションをコンテナから表示するためのX Window System環境が準備されていること。
   * macOS: XQuartz がインストール・実行されていること。
   * Windows: WSL2 と、VcXsrvや、WSLgが有効なWindows 11環境が準備されていること。
   * Linux: 通常は追加設定不要です。
3. 設定手順
Step 1: ホストPCにデータ保存用フォルダを作成
まず、コンテナから保存されるファイルを受け取るための専用フォルダをホストPC上に作成します。ここでは例として、デスクトップにmolecular-dataという名前のフォルダを作成します。
# デスクトップに移動 (環境に合わせてパスを調整してください)
cd ~/Desktop

# データ保存用フォルダを作成
mkdir molecular-data

このmolecular-dataフォルダが、コンテナとの共有ポイントになります。
Step 2: docker run コマンドでバインドマウントを実行
docker runコマンドに-vオプションを追加して、Step 1で作成したフォルダとコンテナ内のフォルダを接続します。
基本コマンド構造
docker run -it --rm \
  -v <ホストの絶対パス>:<コンテナの絶対パス> \
  <GUI接続設定> \
  <イメージ名>

 * -v : ボリューム（ここではバインドマウント）を指定するオプション。
 * <ホストの絶対パス> : 先ほど作成した molecular-data フォルダのフルパス。
 * <コンテナの絶対パス> : コンテナ内からこのフォルダが見える場所。ユーザーのホームディレクトリ内などが分かりやすいでしょう。例: /home/user/data
 * <GUI接続設定> : X Window Systemへ接続するための環境変数やネットワーク設定。
 * <イメージ名> : Python Molecular Editorが含まれるDockerイメージ名。（例: pme-image:latest）
Step 3: プラットフォーム別の実行コマンド
お使いのOSに応じて、以下のコマンドを実行します。
ここでは、ホストの ~/Desktop/molecular-data をコンテナ内の /data にマウントする例を示します。
macOS (XQuartzを使用)
XQuartzを起動し、セキュリティ設定で「ネットワーク・クライアントからの接続を許可」にチェックを入れてください。
# ターミナルでIPアドレスを取得
IP=$(ifconfig en0 | grep inet | awk '$1=="inet" {print $2}')

# 接続を許可
xhost + $IP

# Dockerコンテナを起動
docker run -it --rm \
  -v ~/Desktop/molecular-data:/data \
  -e DISPLAY=${IP}:0 \
  pme-image:latest

Windows (WSL2 + WSLgを使用)
Windows 11のWSLg環境では、GUI設定が自動化されており非常にシンプルです。
# WSLのターミナルから実行
docker run -it --rm \
  -v /mnt/c/Users/<Your-Username>/Desktop/molecular-data:/data \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  pme-image:latest

注意: <Your-Username>はご自身のWindowsユーザー名に置き換えてください。
Linux
最もシンプルに実行できます。
# 接続を許可 (必要な場合)
xhost +local:

# Dockerコンテナを起動
docker run -it --rm \
  -v ~/Desktop/molecular-data:/data \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  pme-image:latest

4. コンテナ内での操作
上記コマンドでコンテナを起動すると、Python Molecular EditorのGUIが表示されます。
 * アプリケーション内で分子モデルを作成または編集します。
 * メニューから「ファイル」→「名前を付けて保存」を選択します。
 * ファイル保存ダイアログが表示されたら、コマンドで指定したマウント先のディレクトリ（この例では /data）に移動します。
 * 任意のファイル名（例: caffeine.xyz）で保存します。
 * 保存が完了すると、ホストPCのデスクトップにあるmolecular-dataフォルダ内にcaffeine.xyzファイルが作成されていることが確認できます。
コンテナをexitコマンドやウィンドウを閉じて終了（--rmオプションにより自動削除）しても、ホストPC上のファイルは完全に保持されます。
5. まとめ
| オプション | 役割 |
|---|---|
| -v <HOST_PATH>:<CONTAINER_PATH> | バインドマウントの核となる設定。 ホストとコンテナのファイルシステムを双方向に同期させる。 |
| -e DISPLAY=... | GUI表示に必須。 コンテナ内のGUIアプリケーションの描画先（ホストのディスプレイ）を指示する。 |
| -v /tmp/.X11-unix... | GUI表示に必須。 Xサーバーとの通信ソケットをコンテナと共有する。 |
この手順により、Dockerのポータビリティと隔離性の恩恵を受けつつ、GUIアプリケーションで生成した重要なデータを安全かつ永続的に管理することが可能になります。
