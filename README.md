<!--
  推奨拡張：yzhang.markdown-all-in-one
  （VS Code の「拡張機能」でインストール後、Ctrl+Shift+V でプレビュー）
-->

# ネットワークデバッグツール チュートリアル集

## 1. netcat (nc)

### インストール
```sh
# Alpine Linux
apk add --no-cache netcat-openbsd
```

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

### インストール
```sh
apk add --no-cache curl
```

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

### インストール
```sh
apk add --no-cache nmap
```

### 基本使い方
```sh
# ホストの全ポートスキャン
nmap -p- 192.168.1.10
# サービス＆OS推定
nmap -sV -O 192.168.1.10
```

---

## 4. mosquitto-clients

### インストール
```sh
apk add --no-cache mosquitto-clients
```

### 基本使い方
```sh
# Subscribe
mosquitto_sub -h localhost -t test/topic
# Publish
mosquitto_pub -h localhost -t test/topic -m "hello"
```

---

## 5. dig / nslookup

### インストール
```sh
apk add --no-cache bind-tools
```

### 基本使い方
```sh
dig example.com A
nslookup example.com
```

---

## 6. ping / traceroute

### インストール
```sh
apk add --no-cache iputils traceroute
```

### 基本使い方
```sh
ping -c 4 8.8.8.8
traceroute example.com
```

---

## 7. tcpdump

### インストール
```sh
apk add --no-cache tcpdump
```

### 基本使い方
```sh
# eth0 のパケットをキャプチャ
tcpdump -i eth0 -w dump.pcap
# 特定ポートのみ
tcpdump -i eth0 port 1883
```

---

## 8. iperf3

### インストール
```sh
apk add --no-cache iperf3
```

### 基本使い方
```sh
# サーバ起動 (別ターミナル)
iperf3 -s
# クライアント接続
iperf3 -c localhost -p 5201
```
