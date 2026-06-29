<!--
  推奨拡張：yzhang.markdown-all-in-one
  （VS Code の「拡張機能」でインストール後、Ctrl+Shift+V でプレビュー）
-->

# ネットワークデバッグツール チュートリアル集

## 0. このコンテナの使い方

各ツールはイメージに同梱済みなので、個別の `apk add` は不要です。

```sh
# シェルに入る（使い捨て）
docker compose run --rm debug

# 常駐させて exec で入る
docker compose up -d
docker compose exec debug sh
```

---

## ツール一覧（レイヤー × カテゴリ）

どの層を触るか（レイヤー）× 何をするか（カテゴリ）でツールを俯瞰する早見表です。

| レイヤー \ カテゴリ | 疎通・経路確認 | 探索・スキャン | キャプチャ・解析 | 接続・中継・送受信 | 名前解決・情報照会 |
|---|---|---|---|---|---|
| **L3/L4（ネットワーク/トランスポート）** | ping / traceroute, mtr | nmap | tcpdump | nc, socat | — |
| **L4+（性能・状態）** | iperf3（帯域計測） | ss（ソケット状態） | — | — | — |
| **L7（アプリケーション）** | — | — | — | curl, websocat, mosquitto-clients | dig / nslookup, whois |
| **セキュリティ（TLS）** | — | — | openssl（証明書検証） | openssl（s_client） | — |
| **設定・補助** | ip（経路/IF確認） | — | — | — | jq（JSON整形） |

> レイヤー軸は OSI への厳密マッピングではなく「どの層を触るか」のざっくり分類です。

### 用途カテゴリ別

| カテゴリ | ツール | 役割 |
|---|---|---|
| **疎通・経路** | ping, traceroute, mtr | 到達性・経路・ロス率 |
| **ポート/サービス探索** | nmap, ss | 開放ポート・サービス・OS推定 |
| **パケット解析** | tcpdump | キャプチャ・フィルタ |
| **接続・中継** | nc, socat, websocat | ソケット送受信・転送・ブリッジ |
| **性能計測** | iperf3 | スループット測定 |
| **アプリ層クライアント** | curl, mosquitto-clients | HTTP / MQTT |
| **DNS・登録情報** | dig, nslookup, whois | 名前解決・登録情報 |
| **TLS/証明書** | openssl | ハンドシェイク・証明書 |
| **IF/ルーティング設定** | ip | アドレス・経路確認 |
| **データ整形** | jq | JSON 抽出・整形 |

---

## 1. netcat (nc)

### 基本使い方
- **ポートリッスン**  
  ```sh
  nc -l 9000
  ```
- **データ送信**  
  ```sh
  echo "hello" | nc 127.0.0.1 9000
  ```

### ワンポイント
- `-k` を付けると接続を維持したまま複数クライアントを受け付けます。

---

## 2. curl

### 基本使い方
- **GET リクエスト**  
  ```sh
  curl http://example.com/api/health
  ```
- **ヘッダ付き POST**  
  ```sh
  curl -X POST -H "Content-Type: application/json" \
       -d '{"foo":"bar"}' \
       http://example.com/api/data
  ```

### ワンポイント
- `-I` でヘッダのみ取得、`-v` で詳細なデバッグログ。

---

## 3. nmap

### 基本使い方
```sh
# ホストの全ポートスキャン
nmap -p- 192.168.1.10
# サービス＆OS推定
nmap -sV -O 192.168.1.10
```

---

## 4. mosquitto-clients

### 基本使い方
```sh
# Subscribe
mosquitto_sub -h localhost -t test/topic
# Publish
mosquitto_pub -h localhost -t test/topic -m "hello"
```

### ワンポイント
- TLS (8883) は CA 証明書を指定: `mosquitto_sub -h broker -p 8883 --cafile ca.crt -t test/#`

---

## 5. dig / nslookup

### 基本使い方
```sh
dig example.com A
nslookup example.com
```

---

## 6. ping / traceroute

### 基本使い方
```sh
ping -c 4 8.8.8.8
traceroute example.com
```

---

## 7. tcpdump

### 基本使い方
```sh
# eth0 のパケットをキャプチャ
tcpdump -i eth0 -w dump.pcap
# 特定ポートのみ
tcpdump -i eth0 port 1883
```

---

## 8. iperf3

### 基本使い方
```sh
# サーバ起動 (別ターミナル)
iperf3 -s
# クライアント接続
iperf3 -c localhost -p 5201
```

---

## 9. socat

nc の上位互換。任意のソケット同士を双方向中継できます。

```sh
# TCP ポートフォワード (8080 → 内部 80)
socat TCP-LISTEN:8080,fork,reuseaddr TCP:backend:80
# 簡易 TCP サーバ (受信を標準出力へ)
socat TCP-LISTEN:9000,fork -
# UNIX ソケット ↔ TCP 橋渡し
socat UNIX-CONNECT:/var/run/app.sock TCP-LISTEN:7000,fork,reuseaddr
```

---

## 10. mtr

`traceroute` と `ping` を統合し、経路ごとのパケットロス率を継続表示します。

```sh
# 対話画面
mtr example.com
# レポートを N 回分まとめて出力 (CI 向け)
mtr -rwc 10 example.com
```

---

## 11. websocat

WebSocket クライアント / サーバ。IoT・リアルタイム系のデバッグに。

```sh
# 接続して対話送受信
websocat ws://localhost:8000/ws
# サーバとして待ち受け、受信をエコー
websocat -s 8080
```

---

## 12. openssl

TLS / 証明書まわりのデバッグ。

```sh
# 接続して証明書チェーンを確認
openssl s_client -connect example.com:443 -servername example.com
# サーバ証明書の有効期限だけ表示
echo | openssl s_client -connect example.com:443 2>/dev/null \
  | openssl x509 -noout -dates
```

---

## 13. ip / ss (iproute2)

`ifconfig` / `netstat` のモダン代替。

```sh
# インターフェイス・アドレス確認
ip addr
# ルーティングテーブル
ip route
# リッスン中の TCP ソケットとプロセス
ss -tlnp
```

---

## 14. jq

`curl` の JSON 出力を整形・抽出。

```sh
curl -s http://example.com/api/data | jq .
curl -s http://example.com/api/items | jq '.[].name'
```

---

## 15. whois

```sh
whois example.com
whois 8.8.8.8
```
