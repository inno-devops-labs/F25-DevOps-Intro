# Lab 4 - Operating Systems and Networking: Submission (Windows)

Auto-generated: 2025-10-03T23:35:55

Note: IPv4 addresses are sanitized (last octet -> XXX).

## Task 1 - Operating System Analysis
### 1.1 Boot and Session Overview
#### Last boot time
10/01/2025 16:30:33

#### Uptime


SystemUpTime : 198323





#### Logged-on users (query user)
N/A

### 1.2 Process Forensics
#### Top by WorkingSet (MEM)

   Id ProcessName               CPU         WS
   -- -----------               ---         --
 6948 pycharm64             676,125 2483064832
 2792 Memory Compression   187,5625  924356608
19852 dwm                533,265625  607178752
10200 Spotify            107,078125  367194112
 5648 MsMpEng            1414,21875  339181568
 9808 chrome                    259  311222272




#### Top by CPU (cumulative)

   Id ProcessName         CPU         WS
   -- -----------         ---         --
 5648 MsMpEng     1414,234375  339181568
 5976 chrome       1283,46875   92590080
    4 System       988,890625   13414400
 6948 pycharm64       676,125 2483064832
19852 dwm          533,265625  607178752
 7984 WmiPrvSE       408,0625   28921856




### 1.3 Running Services

 Status Name                         DisplayName                                                                       
 ------ ----                         -----------                                                                       
Running Appinfo                      Сведения о приложении                                                             
Running AppXSvc                      Служба развертывания AppX (AppXSVC)                                               
Running AudioEndpointBuilder         Средство построения конечных точек Windows Audio                                  
Running Audiosrv                     Windows Audio                                                                     
Running BFE                          Служба базовой фильтрации                                                         
Running BITS                         Фоновая интеллектуальная служба передачи (BITS)                                   
Running BluetoothUserService_5c0b7cf Служба поддержки пользователей Bluetooth_5c0b7cf                                  
Running BrokerInfrastructure         Служба инфраструктуры фоновых задач                                               
Running BTAGService                  Служба звукового шлюза Bluetooth                                                  
Running BthAvctpSvc                  Служба AVCTP                                                                      
Running bthserv                      Служба поддержки Bluetooth                                                        
Running camsvc                       Служба диспетчера доступа к возможностям                                          
Running CaptureService_5c0b7cf       CaptureService_5c0b7cf                                                            
Running cbdhsvc_5c0b7cf              Пользовательская служба буфера обмена_5c0b7cf                                     
Running CDPSvc                       Служба платформы подключенных устройств                                           
Running CDPUserSvc_5c0b7cf           Служба пользователя платформы подключенных устройств_5c0b7cf                      
Running CoreMessagingRegistrar       CoreMessaging                                                                     
Running cphs                         Intel(R) Content Protection HECI Service                                          
Running cplspcon                     Intel(R) Content Protection HDCP Service                                          
Running CryptSvc                     Службы криптографии                                                               
Running DcomLaunch                   Модуль запуска процессов DCOM-сервера                                             
Running DeamonService                DeamonService                                                                     
Running DeviceAssociationService     Служба сопоставления устройств                                                    
Running Dhcp                         DHCP-клиент                                                                       
Running DiagTrack                    Функциональные возможности для подключенных пользователей и телеметрия            
Running DispBrokerDesktopSvc         Служба политики отображения                                                       
Running DisplayEnhancementService    Служба улучшения отображения                                                      
Running Dnscache                     DNS-клиент                                                                        
Running DoSvc                        Оптимизация доставки                                                              
Running DPS                          Служба политики диагностики                                                       
Running DsSvc                        Служба совместного доступа к данным                                               
Running DusmSvc                      Использование данных                                                              
Running EFS                          Шифрованная файловая система (EFS)                                                
Running EventLog                     Журнал событий Windows                                                            
Running EventSystem                  Система событий COM+                                                              
Running fdPHost                      Хост поставщика функции обнаружения                                               
Running FDResPub                     Публикация ресурсов обнаружения функции                                           
Running FontCache                    Служба кэша шрифтов Windows                                                       
Running FontCache3.0.0.XXX             Кэш шрифтов Windows Presentation Foundation 3.0.0.XXX                               
Running hidserv                      Доступ к устройствам HID                                                          
Running hns                          Сетевая служба узла                                                               
Running HvHost                       Служба узла HV                                                                    
Running igccservice                  Intel(R) Graphics Command Center Service                                          
Running igfxCUIService2.0.0.XXX        Intel(R) HD Graphics Control Panel Service                                        
Running IKEEXT                       Модули ключей IPsec для обмена ключами в Интернете и протокола IP с проверкой п...
Running InstallService               Служба установки Microsoft Store                                                  
Running iphlpsvc                     Вспомогательная служба IP                                                         
Running jhi_service                  Intel(R) Dynamic Application Loader Host Interface Service                        
Running KeyIso                       Изоляция ключей CNG                                                               
Running LanmanServer                 Сервер                                                                            
Running LanmanWorkstation            Рабочая станция                                                                   
Running lfsvc                        Служба географического положения                                                  
Running LicenseManager               Служба Windows License Manager                                                    
Running LightKeeperService           LightKeeperService                                                                
Running lmhosts                      Модуль поддержки NetBIOS через TCP/IP                                             
Running LMS                          Intel(R) Management and Security Application Local Management Service             
Running LSM                          Диспетчер локальных сеансов                                                       
Running MDCoreSvc                    Основная служба Microsoft Defender                                                
Running Micro Star SCM               Micro Star SCM                                                                    
Running mpssvc                       Брандмауэр Защитника Windows                                                      




### 1.4 Memory Summary
Total RAM (GB): 15,77
Free  RAM (GB): 5,48
#### Answers / Observations (Task 1)
- Top memory-consuming process: <fill here>
- Patterns: <boot delays, CPU spikes, heavy services>

## Task 2 - Networking Analysis
### 2.1 Network Path Tracing
#### tracert github.com

Трассировка маршрута к github.com [140.82.121.XXX]
с максимальным числом прыжков 30:

  1     1 ms    <1 мс    <1 мс  10.247.1.XXX 
  2    <1 мс    <1 мс    <1 мс  10.250.0.XXX 
  3    <1 мс    <1 мс    <1 мс  10.252.6.XXX 
  4     9 ms     9 ms     9 ms  84.18.123.XXX 
  5     5 ms     5 ms     5 ms  178.176.191.XXX 
  6     *        *        *     Превышен интервал ожидания для запроса.
  7     *        *        *     Превышен интервал ожидания для запроса.
  8     *        *        *     Превышен интервал ожидания для запроса.
  9     *        *        *     Превышен интервал ожидания для запроса.
 10    55 ms    58 ms    61 ms  83.169.204.XXX 
 11    41 ms    40 ms    40 ms  194.68.123.XXX 
 12     *        *        *     Превышен интервал ожидания для запроса.
 13     *        *        *     Превышен интервал ожидания для запроса.
 14     *        *        *     Превышен интервал ожидания для запроса.
 15     *        *        *     Превышен интервал ожидания для запроса.
 16     *        *        *     Превышен интервал ожидания для запроса.
 17     *        *        *     Превышен интервал ожидания для запроса.
 18    55 ms    55 ms    55 ms  94.103.180.XXX 
 19    55 ms    55 ms    55 ms  45.153.82.XXX 
 20     *        *        *     Превышен интервал ожидания для запроса.
 21     *        *        *     Превышен интервал ожидания для запроса.
 22    57 ms    56 ms    57 ms  140.82.121.XXX 

Трассировка завершена.


#### nslookup github.com
N/A

### 2.2 Packet Capture (DNS, tshark)
tshark failed: Capturing on '╨Я╨╛╨┤╨║╨╗╤О╤З╨╡╨╜╨╕╨╡ ╨┐╨╛ ╨╗╨╛╨║╨░╨╗╤М╨╜╨╛╨╣ ╤Б╨╡╤В╨╕* 10'

### 2.3 Reverse DNS
#### nslookup 8.8.4.XXX
╤хЁтхЁ:  dns.google
Address:  8.8.8.XXX

╚ь :     dns.google
Address:  8.8.4.XXX



#### nslookup 1.1.2.XXX
N/A
#### Insights (Task 2)
- Traceroute path: <ISP hops, latency trend>
- DNS records: <A/AAAA/CNAME/NS summary>
- Packet sample (sanitized):
