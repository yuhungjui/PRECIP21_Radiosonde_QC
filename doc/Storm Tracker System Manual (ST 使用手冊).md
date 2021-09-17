# Storm Tracker System Manual (ST 使用手冊)

**Last Update:**
> [time=Apr 6, 2021]
> [name=Hungjui Yu]

---

[TOC]

---

## 0. Storm Tracker System Version

> Firmware: Ver.2.x
> Server: Ver.2.x


## 1. The Ground Receiver 地面接收機

### 1.1. Ground Receiver & Antennas 地面接收機 & 天線
[](https://i.imgur.com/PwoasDo.jpg)
![](https://i.imgur.com/vZhVRnA.jpg)

* Ground Receiver 地面接收機
* Data Radio Antenna 無線電天線
* GPS Antenna GPS天線
* Radio Antenna Base 無線電天線座 — 連接無線電天線與接收機
* USB Adaptor USB轉接頭 — 供電

### 1.2. Connecting to Ground Receiver 接收機外觀（接頭與指示燈）
[](https://i.imgur.com/WeJ8SdM.jpg)
![](https://i.imgur.com/39PIP5I.jpg)

* **Lights on the Ground Receiver 開機與指示燈：**
While working normally, the SYNC light (lower left) power light, WiFi light, GPS light, and Sync Mode light are on (top right on the Ground Receiver). 
正常狀態下電源指示燈、WiFi通訊指示燈、GPS鎖定指示燈、同步模式指示燈會亮(接收機右上角)。接收機是AP模式的時候，WiFi通訊指示燈會亮；有收到GPS訊號時，GPS鎖定指示燈會亮；設定成同步模式(預設)時同步指示燈會亮。
* **Power 電源接口：**
Use 3–16V for Mini USB port with USB adaptor or portable power bank. Or DC power port with DC.
3—16V。使用Mini USB接口，透過USB轉接頭接一般插頭供電，或使用行動電源供電。
* **Channel lights 通道資料指示燈：**
The channel lights (0–9) are On the right of the Ground Receiver, light is on when data incoming through the corresponding channel.
顯示接收機收到哪個通道(0–9)的資料，收到的時候會閃一下對應的通道。

### 1.3. How to start the Ground Receiver? 接收機架設/開機

![](https://i.imgur.com/kqIo533.gif)
    
1. Set up and connect the data and GPS antennas. 
首先先把天線架設好之後，把天線訊號線以及GPS天線接上接收機對應的孔。
[Youtube](https://www.youtube.com/watch?v=FZ3-TfaV3ZQ)
2. The Ground Receiver is on when connecting to power. Normally, the power light, WiFi light, GPS light, and Sync Mode light will on. 
把電源線接上，會看到正常狀態下電源指示燈、WiFi通訊指示燈、GPS鎖定指示燈、同步模式指示燈會亮。

### 1.4. Ground Receiver Settings 接收機啟動/設定/監控

1. Wait for GPS signal. 等待GPS訊號：
GPS light is on when receiving GPS signal, blinking if not. 
如果沒有接GPS天線、或沒有接收到GPS訊號的話，GPS鎖定指示燈會閃爍，接收到之後會恆亮。
![](https://i.imgur.com/EWpNAIC.gif)
2. When the Ground Receiver OS starts, SYNC light will on. Now the Ground Receiver is working. 
接收軟體啟動之後，同步指示燈會亮(接收機左下角)，這時候就開機完成了。
![](https://i.imgur.com/Zfd51BR.gif)
3. Use any device to look for WiFi called (DM_)StormTracker_Receiver_xx. No password needed for connection. 
透過WiFi尋找(DM_)StormTracker_Receiver_[接收機編號]，連上接收機（無需密碼）。
![](https://i.imgur.com/dvKD4yz.jpg)
4. Open your browser and go to http://192.168.100.1, you should see the Storm Tracker System UI.
連線到 http://192.168.100.1 會出現如下圖的網頁，即為使用者操作介面。


## 2. ST System User Interface (UI) 接收機使用者操作介面

![](https://i.imgur.com/duY1pN8.jpg)

### 2.1. Map 地圖
The Map on the top left shows where the Ground Receiver is and all Storm Trackers trace.
左上角的地圖會顯示Ground Receiver 與 Storm Tracker的即時位置。

### 2.2. Realtime Data 即時資料顯示
The table below shows the realtime measurements from all Strom Trackers. Each coulumn is indicated as follows,
下方的資料欄位會顯示所有通道上的 Storm Tracker 的即時資料。
其中幾個比較需要說明的資料的說明如下：

* **Channel — 通道**
10 data receiving channels from 0–9.
代表接收機的接收通道，一共有10個(0–9)。
* **Node Number — 探空儀序號**
Node numbers (serial number) for each Storm Tracker radiosonde. Keep record if needed.
每個 Strom Tracker 上面的序號。實驗操作時需紀錄使用序號以及更新[**序號總表**](https://drive.google.com/file/d/1EMh-dJUfnV0AbgIy1HiTpTmuHOB8r_Zu/view?usp=sharing)！
* **Direction — 航向**
* **Voltage — Storm Tracker 的電壓**
Normally, if AAA(1.5V) battery is used, make sure the voltage is over 1.4V. The signal from ST will be easily lost if below 1.1V.
一般來說，使用AAA鹼性電池(1.5V)，若電壓顯示小於1.1V，則訊號有可能不穩。
* **GPS Height — Storm Tracker GPS海拔高度(未扣除地面施放高度)**
* **RSSI (Received Signal Strength Indicator) — 訊號強度(dB)**
* **SNR (Signal-to-Noise Ratio) — 訊噪比(dB)**

### 2.3. Setting/Downloads 設定/下載
Top right of the UI are the Ground Receiver settings indicated as follows,
右上方的設定則是用來控制接收機的，由上而下的設定是：

* **Sync 同步**
By defalt, it is on to sync with GPS. Unless for specific frequency (channel), you don't need to turn it off.
接收機預設會與GPS同步，除非有特殊理由需要鎖定一個特定頻率，不然不需要關掉(Sync預設為開啟，應該顯示為 on 的狀態)。
* **Select Frequency 設定接收機頻率 Select Frequency**
In case you need to use a specific frequency, turn of the Sync above and specify the frequency as listed.
接收機預設會與GPS同步，所以需要把上面的同步關掉，然後透過這個設定頻率。編號和頻率的關係如下:

    | Number 編號 | Frequency 頻率(MHz) |
    | ---- | --------- |
    | 0    | 432.0     |
    | 1    | 432.5     |
    | 2    | 433.0     |
    | 3    | 433.5     |
    | 4    | 434.0     |
    | 5    | 434.5     |
    | 6    | 435.0     |
    | 7    | 435.5     |
    | 8    | 436.0     |
    | 9    | 436.5     |

* **Get GPS 詢問接收機GPS位置**
Press to retrieve the Ground Receiver GPS location on the Map.
按下去之後接收機會回傳GPS位置，並且更新在地圖上。
* **Connected 和接收機連線**
If the UI is shown, the Ground Receiver is connected. In case the UI freezes, press this to restart. (**The newer version of Ground Receiver restarts automatically if the UI stops**)
網頁能夠打開表示有連接上接收機，但是假如網頁在實驗當中連線有中斷的話，可以透過這個開關重新和接收機連線。**目前最新版本的接收機，網頁若無法連線，系統會自動重新啟動。**
* **List of Data/Current Data下載資料**
    * Press Current Data to download the current measurements since the last time Ground Receiver starts. 
按下 Current Data 按鍵即可下載目前寫入的單筆檔案。
    * For previous data, press List of Data to download manually.
如果需要查看/下載之前的檔案，可以按List of Data顯示檔案列表，即可下載之前的檔案紀錄。
![](https://i.imgur.com/I678qdL.png)


## 3. Storm Tracker (ST) Radiosonde 探空儀

### 3.1. Turn on the ST Radiosonde 探空儀開機

1. Attach a AAA battery and turn on the switch on the back. 
ST背面裝上電池之後把開關打開：
You will see red light if turned on.
打開之後會看到正面電源指示燈(紅)亮起來，這時候代表ST已開啟。
[](https://i.imgur.com/hjUa4IX.jpg)
![](https://i.imgur.com/qFIf8Je.jpg)

If the red light is off when turned on, it could be one of the following reasons, 
若是ST開關數次後紅燈仍未亮，原因可能為以下幾點：
* Dead battery or poor contact. Try replacing or reattaching the battery. 
電池沒電或接觸不良，換電池或重新裝上電池。
* ST shortage or malfunction. Replace the ST and keep record if needed.
ST短路或故障(需紀錄在[**序號總表**](https://drive.google.com/file/d/1EMh-dJUfnV0AbgIy1HiTpTmuHOB8r_Zu/view?usp=sharing)並回收ST！)

2. Wait for GPS.
等待GPS訊號：
Take the ST outside, if the green light is on and blinking, the GPS is locked and you will see data on UI, and blinking channel lights on the Ground Receiver.
把探空儀放到戶外等GPS訊號，鎖定之後會看到正面GPS指示燈(綠)亮起+閃爍，此時會在操作介面上看到資料進來。
Mind the following points, 
此步驟需特別注意以下幾點：

* The white rectangle on the front top right of the ST is the GPS antenna. Make sure there is no blockage or shades when waiting for GPS.
探空儀的上方是GPS天線，等候訊號時盡量確保沒有遮蔽。
* **During waiting, make sure the ST is well ventilated in case of any temperature/moisture biases caused by direct solar heating or heated surface.
等候訊號時需確保ST在通風良好的陰暗處，避免因日照或接觸高溫表面，使升空前溫濕度異常！**
* If the waiting is too long (say over 15 min), replace a different ST and keep recond if needed.
若超過15分鐘(或實驗許可時間範圍)仍未收到GPS訊號，則紀錄在[**序號總表**](https://drive.google.com/file/d/1EMh-dJUfnV0AbgIy1HiTpTmuHOB8r_Zu/view?usp=sharing)並回收ST！

### 3.2. Checking List 發射前措施 (*Important! 重要！*)

**Make sure you check these points before launch!
以下幾點發射前措施非常重要！請實驗操作人員務必實施！**

- [ ] It is highly recommended that a well-calibrated barometer is nearby on the same height as the ST launch site in order to get the accurate surface pressure.
ST探空站點需有經過合理校正(well-calibrated)之氣壓計，作為地面氣壓與高度之基準。
- [ ] While waiting for GPS, make sure the ST is well-ventilated in case of any temperature/moisture biases caused by direct solar heating or heated surface.
等候訊號時需確保ST在通風良好的陰暗處，避免因日照或接觸高溫表面，使升空前溫濕度異常！
- [ ] Except for special needs, the recommended buoyancy for the balloon is over 80g, and length of string longer than 5m.
除非實驗需求或特殊天氣狀況，建議ST探空氣球浮力 ≥80g ；線長 ≥5m。
- [ ] Before launch, make sure ... 升空前確保：
    * The ST is well-ventilated and represents the proper measurements for the surroundings.
ST有正常通風與環境平衡，氣壓、溫濕度數值正常且穩定。
    * Voltage of battery over 1.4V. Change a battery if the voltage is too low. 
電壓讀數 ≥1.4V，比這個小的話最好換一顆電池。
    * RSSI over -70dB (better over -50dB). 
RSSI的讀數依照距離接收機的遠近，近的話大約-50dB左右，遠一點的話至少也要-70dB，確保接收機的天線正常接上。
    * GPS satellites more than 4. The more the better.
GPS衛星數 ≥4，越多越好。
- [ ] Keep detailed recond of the launch time (to seconds).
升空時務必紀錄發射時間 [時、分、秒] (精度為秒)，以供後續判定正確升空時間。
- [ ] Keep accurate and detailed log.
正常升空後，紀錄使用狀況於[**序號總表**](https://drive.google.com/file/d/1EMh-dJUfnV0AbgIy1HiTpTmuHOB8r_Zu/view?usp=sharing)。

## 4. Data process 資料處理

### 4.1. Merge Data 資料轉檔/合併
The data downloaded from the UI is the raw data which need translation. Use the following program (.py/.exe) to translate and merge data from one or more Ground Receiver. 
透過操作介面下載完的資料是接收機開機之後所有的原始資料，需要透過轉檔程式翻譯。若是實驗設計有多台接收機同步實驗，轉檔程式也能合併(或各別處理)所有接收機的資料。

* Program 轉檔程式(For Mac/Linux .py)：[Download 下載](https://drive.google.com/file/d/1G2gwaRw-JhfBPTNxFAumg5ZL0J-ZYnqF/view?usp=sharing)
* Program  轉檔軟體(For Windows .exe)：[Download 下載](https://drive.google.com/file/d/17QrFO87xct9EF5QO63hqslqRCGmM7mXf/view?usp=sharing)

### 4.2. How to translate/merge data? 轉檔/合併方式

1. Put the raw data (file names start with LoRa_) and the program under the same path.
把轉檔程式或軟體和原始資料(檔名LoRa_開頭)放在同個資料夾內。
![](https://i.imgur.com/el1dVjw.png)

2. For .exe, just run it. It stops when it is finished.
若使用轉檔軟體，點選轉檔軟體執行即可。看到轉檔完畢就可以關閉了。
![](https://i.imgur.com/ThdSGGr.png)

3. For .py, execute the following,
若使用轉檔程式，則在該資料夾內執行
```
python3 ./MergeRaw.py
```

4. The translated/merged data will be under the same path. 
轉好的資料會在同個資料夾內。
**File name: no[number]yyyymmddHHMM.csv
檔名: no[編號]yyyymmddHHMM.csv***
![](https://i.imgur.com/SidCuzk.png)

5. The translated/merged data is the so-called L0 data for further QA/QC precess. Contact Dr. Hungjui Yu for more details on the next QA/QC steps. 
依照上述步驟處理好的ST資料在QAQC的程序上即判定為 Level 0 (L0)的資料。若實驗需要校正後的ST資料(L1–4)，後續的資料校正 (Data Correction) 與資料整理統一透過 [大氣水文研究資料庫](https://dbar.pccu.edu.tw/) 進行。或與尤虹叡博士聯絡。


## 5. Troubleshooting 故障排除

### 5.1. Storm Tracker power light is off and/or shows very odd T or RH when it is on the groud 電源指示燈未亮/溫濕度異常
* Make sure the battery is properly attached, reboot the ST.
確認電池正確裝上，重開 Storm Tracker。
* If not working, there is probably a shortage on the ST. Replace the ST and keep record.
若仍然不正常則能是短路，需紀錄在[**序號總表**](https://drive.google.com/file/d/1EMh-dJUfnV0AbgIy1HiTpTmuHOB8r_Zu/view?usp=sharing)並回收ST！

### 5.2. Storm Tracker green light is on but no incoming data 綠燈亮了之後機收機沒有訊號

* First, make sure the Ground Receiver GPS light is on.
首先先確定接收機的GPS鎖定指示燈有亮。
* Make sure the Ground Receiver is in Sync mode.
再確定接收機有設定成Sync模式。
* If no data for too long (say 15 min), replace the ST and keep record.
若超過15分鐘(或實驗許可時間範圍)仍未收到GPS訊號，則紀錄在[**序號總表**](https://drive.google.com/file/d/1EMh-dJUfnV0AbgIy1HiTpTmuHOB8r_Zu/view?usp=sharing)並回收ST！

### 5.3. Storm Tracker lost signal immediately after launch 升空後一下子就沒有訊號

* Make sure the Data Antenna is tightly attached.
確定天線接頭有鎖緊。
* If the weather is bad, the ST transmission could be affected. Contact other sites for recovering data if possible. Otherwise, re-launch if needed.
如果天氣狀況不佳的話，也有可能 Storm Tracker 受天候影響掛掉了。這時候可以跟其他站交叉比對，如果其他站都沒有收到訊號的話就可以確定是儀器的問題。

### 5.4. UI is not working 接收機的網頁掛掉

The newer version of Ground Receiver restarts the UI automatically if it stops. If not, manually restart the Ground Receiver through the following steps.
目前最新版本的接收機，網頁若無法連線，系統會自動重新啟動。若是仍然無法啟動或有其他問題出現，則需要斷電全部重新設置。手動啟動步驟如下：

1. Reboot by reconnecting the power to the Ground Receiver.
電源拔掉重開機。


2. Restart the Ground Receiver server through the following steps,
按照以下步驟重開地面接收機伺服器。
* SSH to the Ground Receiver. 
首先透過ssh連上接收機
```
ssh root@192.168.100.1
User Password: cook1234
```
* Type the following,
然後打下列指令
```
screen
cd /Media/SD-P1/receiver/
node app.js
```
The following shows when the server is running. You can keep it to monitor the Ground Receiver if needed. Or type the following whenever you want to monitor,
以下畫面就是軟體的執行畫面，可以留在這邊監控。如果之後斷開想要再連回去可以打下列指令：
```
screen -r
```
![](https://i.imgur.com/eNCSqxJ.png)
![](https://i.imgur.com/NfMp3SI.png)

### 5.5. Manually download the data 手動資料下載

*  All the data is stored in the SD card on the Ground Receiver. You can SCP those data from the Ground Receiver if needed (winscp if you are using a Windows machine).
所有的資料都存放在接收機的SD卡當中，除了在網頁界面上下載之外，也可以用scp的方式下載回來(若使用軟體的話，推薦winscp)。
```
scp -r root@192.168.100.1:/Media/SD-P1/receiver/data/ ./your_folder
``` 

## 6. References 參考資料

> [DBAR 大氣水文研究資料庫](https://dbar.pccu.edu.tw/)
> [Storm Tracker 探空系統檔案](https://hackmd.io/@xjcokueQTyKvnfndH4fLWA/StormTrackerSystemFIles)
> [Storm Tracker 探空系統周邊耗材零件廠商](https://hackmd.io/@xjcokueQTyKvnfndH4fLWA/StormTrackerSystemSupplies)