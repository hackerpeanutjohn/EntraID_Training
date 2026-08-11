# Entra ID Training Codespace

這個 repository 只用來建立課程 Codespace。你不需要安裝 Docker Desktop。

> 請使用課程發放的 Entra ID 帳號。不要拿個人或公司的正式帳號做 Lab。

## 建立課程環境

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/hackerpeanutjohn/EntraID_Training)

1. 使用個人 GitHub 帳號登入。
2. Machine type 保持預設的 2-core。
3. 確認 Codespace 使用量由你的個人 GitHub 帳號計算。
4. 點選 **Create codespace**。
5. 等瀏覽器版 VS Code 與 Terminal 開啟。

## 啟動 Lab

Codespace 第一次建立時會從 private GitHub Release 自動下載 `roadrecon.db`，並驗證 SHA-256。學生不需要手動上傳檔案。

在 Codespaces Terminal 執行：

```bash
bash scripts/start-lab.sh
```

看到 `Lab workstation is ready` 後：

1. 打開 VS Code 下方的 **PORTS** 分頁。
2. 找到 `6080`。
3. 確認 Visibility 為 **Private**，不要改成 Public。
4. 點選地球圖示或 **Open in Browser**。
5. 確認 Linux 桌面與 LXTerminal 可以開啟。

需要 ROADrecon GUI 時使用 Port `15000`，一樣必須保持 **Private**。

## 進入 CLI

```bash
docker compose exec workstation bash
```

進入後的工作目錄應為 `/workspace`。

## 暫停與重新開啟

暫停 Lab，但保留 `/workspace`：

```bash
bash scripts/stop-lab.sh
```

重新開啟 Codespace 後，再執行：

```bash
bash scripts/start-lab.sh
```

## 下課後清理

確定不再需要 `/workspace` 裡的資料後執行：

```bash
bash scripts/stop-lab.sh --delete-workspace
```

接著開啟 [Your codespaces](https://github.com/codespaces)，找到這堂課的 Codespace，從右側 `...` 選擇 **Delete**。

只關閉瀏覽器分頁不代表 Codespace 已刪除。

## 常見問題

### 無法下載 `roadrecon.db`

在 Terminal 執行：

```bash
bash scripts/fetch-roadrecon-snapshot.sh
```

如果仍失敗，把完整輸出交給講師。不要自行建立空白檔案，否則後面的 ROADrecon Lab 會失敗。

### Port `6080` 沒出現

在 **PORTS** 分頁選擇 **Add Port**，輸入 `6080`，確認 Visibility 為 **Private**。

### Workstation 沒有變成 healthy

```bash
docker compose ps
docker compose logs --tail=100 workstation
```

把輸出交給講師，不要一直刪掉重建。
