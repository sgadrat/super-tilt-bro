;-------------------------------------------------------------------------------
; Commands from NES to ESP
;-------------------------------------------------------------------------------

; ESP CMDS
TOESP_MSG_GET_ESP_STATUS                   = 0   ; Get ESP status
TOESP_MSG_DEBUG_GET_LEVEL                  = 1   ; Get debug level
TOESP_MSG_DEBUG_SET_LEVEL                  = 2   ; Set debug level
TOESP_MSG_DEBUG_LOG                        = 3   ; Debug / Log data
TOESP_MSG_CLEAR_BUFFERS                    = 4   ; Clear RX/TX buffers
TOESP_MSG_FROMESP_MSG_BUFFER_DROP_FROM_ESP = 5   ; Drop messages from TX (ESP->outside world) buffer
TOESP_MSG_ESP_GET_FIRMWARE_VERSION         = 6   ; Get Rainbow firmware version
TOESP_MSG_ESP_FACTORY_RESET                = 7   ; Reset ESP to factory settings
TOESP_MSG_ESP_RESTART                      = 8   ; Restart ESP

; WIFI CMDS
TOESP_MSG_WIFI_GET_STATUS                  = 9   ; Get WiFi connection status
TOESP_MSG_WIFI_GET_SSID                    = 10  ; Get WiFi network SSID
TOESP_MSG_WIFI_GET_IP                      = 11  ; Get WiFi IP address

; AP CMDS
TOESP_MSG_WIFI_GET_CONFIG                  = 12  ; Get WiFi / Access Point / Web Server config
TOESP_MSG_WIFI_SET_CONFIG                  = 13  ; Set WiFi / Access Point / Web Server config
TOESP_MSG_AP_GET_SSID                      = 14  ; Get Access Point network SSID
TOESP_MSG_AP_GET_IP                        = 15  ; Get Access Point IP address

; RND CMDS
TOESP_MSG_RND_GET_BYTE                     = 16  ; Get random byte
TOESP_MSG_RND_GET_BYTE_RANGE               = 17  ; Get random byte between custom min/max
TOESP_MSG_RND_GET_WORD                     = 18  ; Get random word
TOESP_MSG_RND_GET_WORD_RANGE               = 19  ; Get random word between custom min/max

; SERVER CMDS
TOESP_MSG_SERVER_GET_STATUS                = 20  ; Get server connection status
TOESP_MSG_SERVER_PING                      = 21  ; Get ping between ESP and server
TOESP_MSG_SERVER_SET_PROTOCOL              = 22  ; Set protocol to be used to communicate (WS/UDP)
TOESP_MSG_SERVER_GET_SETTINGS              = 23  ; Get current server host name and port
TOESP_MSG_SERVER_SET_SETTINGS              = 24  ; Set current server host name and port
TOESP_MSG_SERVER_GET_SAVED_SETTINGS        = 25  ; Get server host name and port defined in the Rainbow config file
TOESP_MSG_SERVER_SET_SAVED_SETTINGS        = 26  ; Set server host name and port defined in the Rainbow config file
TOESP_MSG_SERVER_RESTORE_SAVED_SETTINGS    = 27  ; Restore server host name and port to values defined in the Rainbow config
TOESP_MSG_SERVER_CONNECT                   = 28  ; Connect to server
TOESP_MSG_SERVER_DISCONNECT                = 29  ; Disconnect from server
TOESP_MSG_SERVER_SEND_MESSAGE              = 30  ; Send message to server

; NETWORK CMDS
TOESP_MSG_NETWORK_SCAN                     = 31  ; Scan networks around and return count
TOESP_MSG_NETWORK_GET_SCANNED_DETAILS      = 32  ; Get scanned network details
TOESP_MSG_NETWORK_GET_REGISTERED           = 33  ; Get registered networks status
TOESP_MSG_NETWORK_GET_REGISTERED_DETAILS   = 34  ; Get registered network SSID
TOESP_MSG_NETWORK_REGISTER                 = 35  ; Register network
TOESP_MSG_NETWORK_UNREGISTER               = 36  ; Unregister network
TOESP_MSG_NETWORK_SET_ACTIVE               = 37  ; Set active network

; FILE COMMANDS
TOESP_MSG_FILE_OPEN                        = 38  ; Open working file
TOESP_MSG_FILE_CLOSE                       = 39  ; Close working file
TOESP_MSG_FILE_STATUS                      = 40  ; Get working file status
TOESP_MSG_FILE_EXISTS                      = 41  ; Check if file exists
TOESP_MSG_FILE_DELETE                      = 42  ; Delete a file
TOESP_MSG_FILE_SET_CUR                     = 43  ; Set working file cursor position a file
TOESP_MSG_FILE_READ                        = 44  ; Read working file (at specific position)
TOESP_MSG_FILE_WRITE                       = 45  ; Write working file (at specific position)
TOESP_MSG_FILE_APPEND                      = 46  ; Append data to working file
TOESP_MSG_FILE_COUNT                       = 47  ; Count files in a specific path
TOESP_MSG_FILE_GET_LIST                    = 48  ; Get list of existing files in a path
TOESP_MSG_FILE_GET_FREE_ID                 = 49  ; Get an unexisting file ID in a specific path
TOESP_MSG_FILE_GET_FS_INFO                 = 50  ; Get file system details (ESP flash or SD card)
TOESP_MSG_FILE_GET_INFO                    = 51  ; Get file info (size + crc32)
TOESP_MSG_FILE_DOWNLOAD                    = 52  ; Download a file from a giving URL to a specific path index / file index
TOESP_MSG_FILE_FORMAT                      = 53  ; Format file system

;-------------------------------------------------------------------------------
; Commands from ESP to NES
;-------------------------------------------------------------------------------

; ESP CMDS
FROMESP_MSG_READY                          = 0   ; ESP is ready
FROMESP_MSG_DEBUG_LEVEL                    = 1   ; Returns debug configuration
FROMESP_MSG_ESP_FIRMWARE_VERSION           = 2   ; Returns the Rainbow firmware version
FROMESP_MSG_ESP_FACTORY_RESET              = 3   ; Returns ESP reset's return code

; WIFI / AP CMDS
FROMESP_MSG_WIFI_STATUS                    = 4   ; Returns WiFi connection status
FROMESP_MSG_SSID                           = 5   ; WiFi/AccessPoint SSID
FROMESP_MSG_IP_ADDRESS                     = 6   ; WiFi/AccessPoint IP address
FROMESP_MSG_WIFI_CONFIG                    = 7   ; Returns WiFi config

; RND CMDS
FROMESP_MSG_RND_BYTE                       = 8   ; Returns random byte value
FROMESP_MSG_RND_WORD                       = 9   ; Returns random word value

; SERVER CMDS
FROMESP_MSG_SERVER_STATUS                  = 10  ; Returns server connection status
FROMESP_MSG_SERVER_PING                    = 11  ; Returns min, max and average round-trip time and number of lost packets
FROMESP_MSG_SERVER_SETTINGS                = 12  ; Returns server settings (host name + port)
FROMESP_MSG_MESSAGE_FROM_SERVER            = 13  ; Message from server

; NETWORK CMDS
FROMESP_MSG_NETWORK_COUNT                  = 14  ; Returns number of networks found
FROMESP_MSG_NETWORK_SCANNED_DETAILS        = 15  ; Returns details for a scanned network
FROMESP_MSG_NETWORK_REGISTERED_DETAILS     = 16  ; Returns SSID for a registered network
FROMESP_MSG_NETWORK_REGISTERED             = 17  ; Returns registered networks status

; FILE CMDS
FROMESP_MSG_FILE_STATUS                    = 18  ; Returns the working file status
FROMESP_MSG_FILE_EXISTS                    = 19  ; Returns if file exists or not
FROMESP_MSG_FILE_DELETE                    = 20  ; Returns when trying to delete a file
FROMESP_MSG_FILE_LIST                      = 21  ; Returns path file list (FILE_GET_LIST)
FROMESP_MSG_FILE_DATA                      = 22  ; Returns file data (FILE_READ)
FROMESP_MSG_FILE_COUNT                     = 23  ; Returns file count in a specific path
FROMESP_MSG_FILE_ID                        = 24  ; Returns a free file ID (FILE_GET_FREE_ID)
FROMESP_MSG_FILE_FS_INFO                   = 25  ; Returns file system info (FILE_GET_FS_INFO)
FROMESP_MSG_FILE_INFO                      = 26  ; Returns file info (size + CRC32) (FILE_GET_INFO)
FROMESP_MSG_FILE_DOWNLOAD                  = 27  ; Returns download result code

;-------------------------------------------------------------------------------
; Constants to be used in commands
;-------------------------------------------------------------------------------

; Server protocol
ESP_PROTOCOL_TCP               = 0
ESP_PROTOCOL_TCP_SECURED       = 1
ESP_PROTOCOL_UDP               = 2

; Wi-Fi status
ESP_WIFI_STATUS_IDLE_STATUS     = 0
ESP_WIFI_STATUS_NO_SSID_AVAIL   = 1
ESP_WIFI_STATUS_SCAN_COMPLETED  = 2
ESP_WIFI_STATUS_CONNECTED       = 3
ESP_WIFI_STATUS_CONNECT_FAILED  = 4
ESP_WIFI_STATUS_CONNECTION_LOST = 5
ESP_WIFI_STATUS_WRONG_PASSWORD  = 6
ESP_WIFI_STATUS_DISCONNECTED    = 7

; Filesystem directories
ESP_FILE_PATH_SAVE = 0
ESP_FILE_PATH_ROMS = 1
ESP_FILE_PATH_USER = 2

; File open options
ESP_FILE_MODE_AUTO = %00000000
ESP_FILE_MODE_MANUAL = %00000001

; File delete results
ESP_FILE_DELETE_SUCCESS                   = 0
ESP_FILE_DELETE_ERROR_WHILE_DELETING_FILE = 1
ESP_FILE_DELETE_FILE_NOT_FOUND            = 2
ESP_FILE_DELETE_INVALID_PATH_OR_FILE      = 3

; File download results
ESP_FILE_DOWNLOAD_SUCCESS                   = 0 ; Success (HTTP status in 2xx)
ESP_FILE_DOWNLOAD_INVALID_DESTINATION       = 1 ; Invalid destination (path/filename)
ESP_FILE_DOWNLOAD_ERROR_WHILE_DELETING_FILE = 2 ; Error while deleting existing file
ESP_FILE_DOWNLOAD_UNKNOWN_PROTOCOL          = 3 ; Unknown / unsupported protocol
ESP_FILE_DOWNLOAD_NETWORK_ERROR             = 4 ; Network error
ESP_FILE_DOWNLOAD_HTTP_ERROR                = 5 ; HTTP status is not in 2xx

ESP_FILE_DOWNLOAD_NETWORK_ERROR_CONNECTION_FAILED  = 255 ; Connection failed
ESP_FILE_DOWNLOAD_NETWORK_ERROR_SEND_HEADER_FAILED = 254 ; Send header failed
ESP_FILE_DOWNLOAD_NETWORK_ERROR_SEND_PAYLOAD_FILED = 253 ; Send payload failed
ESP_FILE_DOWNLOAD_NETWORK_ERROR_NOT_CONNECTED      = 252 ; Not connected
ESP_FILE_DOWNLOAD_NETWORK_ERROR_CONNECTION_LOST    = 251 ; Connection lost
ESP_FILE_DOWNLOAD_NETWORK_ERROR_NO_STREAM          = 250 ; No stream
ESP_FILE_DOWNLOAD_NETWORK_ERROR_NO_HTTP_SERVER     = 249 ; No HTTP server
ESP_FILE_DOWNLOAD_NETWORK_ERROR_OUT_OF_RAM         = 248 ; Too less RAM
ESP_FILE_DOWNLOAD_NETWORK_ERROR_ENCODING           = 247 ; Encoding
ESP_FILE_DOWNLOAD_NETWORK_ERROR_STREAM_WRITE       = 246 ; Stream write
ESP_FILE_DOWNLOAD_NETWORK_ERROR_READ_TIMEOUT       = 245 ; Read timeout

; ESP reset results
ESP_FACTORY_RESET_SUCCESS = 0
ESP_FACTORY_RESET_ERROR_WHILE_RESETTING_CONFIG = 1
ESP_FACTORY_RESET_ERROR_WHILE_DELETING_TWEB = 2
ESP_FACTORY_RESET_ERROR_WHILE_DELETING_WEB = 3

;-------------------------------------------------------------------------------
; Rainbow registers
;-------------------------------------------------------------------------------

RAINBOW_PRG_BANKING_MODE = $4100

RAINBOW_PRG_ROM_BANKING_1_HI = $4108
RAINBOW_PRG_ROM_BANKING_2_HI = $4109
RAINBOW_PRG_ROM_BANKING_3_HI = $410a
RAINBOW_PRG_ROM_BANKING_4_HI = $410b
RAINBOW_PRG_ROM_BANKING_5_HI = $410c
RAINBOW_PRG_ROM_BANKING_6_HI = $410d
RAINBOW_PRG_ROM_BANKING_7_HI = $410e
RAINBOW_PRG_ROM_BANKING_8_HI = $410f
RAINBOW_PRG_ROM_BANKING_1_LO = $4118
RAINBOW_PRG_ROM_BANKING_2_LO = $4119
RAINBOW_PRG_ROM_BANKING_3_LO = $411a
RAINBOW_PRG_ROM_BANKING_4_LO = $411b
RAINBOW_PRG_ROM_BANKING_5_LO = $411c
RAINBOW_PRG_ROM_BANKING_6_LO = $411d
RAINBOW_PRG_ROM_BANKING_7_LO = $411e
RAINBOW_PRG_ROM_BANKING_8_LO = $411f

RAINBOW_PRG_RAM_BANKING_1_HI = $4106
RAINBOW_PRG_RAM_BANKING_2_HI = $4107
RAINBOW_PRG_RAM_BANKING_1_LO = $4116
RAINBOW_PRG_RAM_BANKING_2_LO = $4117

RAINBOW_FPGA_RAM_BANKING = $4115

RAINBOW_CHR_CONTROL = $4120

RAINBOW_EXT_BG_BANK_HI = $4121

RAINBOW_NAMETABLES_BANK_1 = $4126
RAINBOW_NAMETABLES_BANK_2 = $4127
RAINBOW_NAMETABLES_BANK_3 = $4128
RAINBOW_NAMETABLES_BANK_4 = $4129

RAINBOW_NAMETBALES_CTRL_1 = $412a
RAINBOW_NAMETBALES_CTRL_2 = $412b
RAINBOW_NAMETBALES_CTRL_3 = $412c
RAINBOW_NAMETBALES_CTRL_4 = $412d

RAINBOW_NAMETABLES_SPLIT_BANK = $412e
RAINBOW_NAMETABLES_SPLIT_CTRL = $412f

RAINBOW_CHR_BANKING_1_HI = $4130
RAINBOW_CHR_BANKING_2_HI = $4131
RAINBOW_CHR_BANKING_3_HI = $4132
RAINBOW_CHR_BANKING_4_HI = $4133
RAINBOW_CHR_BANKING_5_HI = $4134
RAINBOW_CHR_BANKING_6_HI = $4135
RAINBOW_CHR_BANKING_7_HI = $4136
RAINBOW_CHR_BANKING_8_HI = $4137
RAINBOW_CHR_BANKING_9_HI = $4138
RAINBOW_CHR_BANKING_10_HI = $4139
RAINBOW_CHR_BANKING_11_HI = $413a
RAINBOW_CHR_BANKING_12_HI = $413b
RAINBOW_CHR_BANKING_13_HI = $413c
RAINBOW_CHR_BANKING_14_HI = $413d
RAINBOW_CHR_BANKING_15_HI = $413e
RAINBOW_CHR_BANKING_16_HI = $413f
RAINBOW_CHR_BANKING_1_LO = $4140
RAINBOW_CHR_BANKING_2_LO = $4141
RAINBOW_CHR_BANKING_3_LO = $4142
RAINBOW_CHR_BANKING_4_LO = $4143
RAINBOW_CHR_BANKING_5_LO = $4144
RAINBOW_CHR_BANKING_6_LO = $4145
RAINBOW_CHR_BANKING_7_LO = $4146
RAINBOW_CHR_BANKING_8_LO = $4147
RAINBOW_CHR_BANKING_9_LO = $4148
RAINBOW_CHR_BANKING_10_LO = $4149
RAINBOW_CHR_BANKING_11_LO = $414a
RAINBOW_CHR_BANKING_12_LO = $414b
RAINBOW_CHR_BANKING_13_LO = $414c
RAINBOW_CHR_BANKING_14_LO = $414d
RAINBOW_CHR_BANKING_15_LO = $414e
RAINBOW_CHR_BANKING_16_LO = $414f

RAINBOW_SCANLINE_IRQ_LATCH = $4150
RAINBOW_SCANLINE_IRQ_CONTROL = $4151
RAINBOW_SCANLINE_IRQ_DISABLE = $4152
RAINBOW_SCANLINE_IRQ_OFFSET = $4153
RAINBOW_SCANLINE_IRQ_JITTER_CNT = $4154

RAINBOW_CPU_CYCLES_IRQ_COUNTER_LO = $4158
RAINBOW_CPU_CYCLES_IRQ_COUNTER_HI = $4159
RAINBOW_CPU_CYCLES_IRQ_CONTROL = $415a
RAINBOW_CPU_CYCLES_IRQ_ACK = $415b

RAINBOW_MAPPER_VERSION = $4160

RAINBOW_IRQ_STATUS = $4161

RAINBOW_WINDOW_SPLIT_X_START = $4170
RAINBOW_WINDOW_SPLIT_X_END = $4171
RAINBOW_WINDOW_SPLIT_Y_START = $4172
RAINBOW_WINDOW_SPLIT_Y_END = $4173
RAINBOW_WINDOW_SPLIT_X_SCROLL = $4174
RAINBOW_WINDOW_SPLIT_Y_SCROLL = $4175

RAINBOW_WIFI_CONF = $4190
RAINBOW_WIFI_RX = $4191
RAINBOW_WIFI_TX = $4192
RAINBOW_WIFI_RX_DEST = $4193
RAINBOW_WIFI_TX_SOURCE = $4194

RAINBOW_PULSE_CHANNEL_1_CONTROL = $41a0
RAINBOW_PULSE_CHANNEL_1_FREQ_LOW = $41a1
RAINBOW_PULSE_CHANNEL_1_FREQ_HIGH = $41a2
RAINBOW_PULSE_CHANNEL_2_CONTROL = $41a3
RAINBOW_PULSE_CHANNEL_2_FREQ_LOW = $41a4
RAINBOW_PULSE_CHANNEL_2_FREQ_HIGH = $41a5
RAINBOW_SAW_CHANNEL_ACCUMULATOR = $41a6
RAINBOW_SAW_CHANNEL_FREQ_LOW = $41a7
RAINBOW_SAW_CHANNEL_FREQ_HIGH = $41a8

RAINBOW_AUDIO_OUTPUT_CONTROL = $41a9

; Aliases
RAINBOW_PRG_BANK_8000_MODE_1_HI = RAINBOW_PRG_ROM_BANKING_1_HI
RAINBOW_PRG_BANK_8000_MODE_1_LO = RAINBOW_PRG_ROM_BANKING_1_LO
RAINBOW_PRG_BANK_C000_MODE_1_HI = RAINBOW_PRG_ROM_BANKING_5_HI
RAINBOW_PRG_BANK_C000_MODE_1_LO = RAINBOW_PRG_ROM_BANKING_5_LO

;-------------------------------------------------------------------------------
; Message parsing constants
;-------------------------------------------------------------------------------

ESP_MSG_SIZE = 0
ESP_MSG_TYPE = 1
ESP_MSG_PAYLOAD = 2

;-------------------------------------------------------------------------------
; Utility macros
;-------------------------------------------------------------------------------

; Hardcoded position of the buffers for convenience routines
;  If you change buffers positions (RAINBOW_WIFI_RX_DEST/TX_DEST), you should update it
esp_rx_buffer = $4800
esp_tx_buffer = $4900

; Helper macro, calling esp_send_cmd on a known label
#define ESP_SEND_CMD(data) \
	lda #<(data) :\
	sta tmpfield1 :\
	lda #>(data) :\
	sta tmpfield1+1 :\
	jsr esp_send_cmd

; Enabled or disable features of the ESP
#define ESP_ENABLE(esp,irq) \
	lda #(irq<<1)+esp :\
	sta RAINBOW_WIFI_CONF
