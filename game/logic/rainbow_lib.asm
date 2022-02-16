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
TOESP_MSG_ESP_RESTART                      = 7   ; Restart ESP

; WIFI CMDS
TOESP_MSG_WIFI_GET_STATUS                  = 8   ; Get WiFi connection status
TOESP_MSG_WIFI_GET_SSID                    = 9   ; Get WiFi network SSID
TOESP_MSG_WIFI_GET_IP                      = 10  ; Get WiFi IP address

; AP CMDS
TOESP_MSG_AP_GET_SSID                      = 11  ; Get Access Point network SSID
TOESP_MSG_AP_GET_IP                        = 12  ; Get Access Point IP address
TOESP_MSG_AP_GET_CONFIG                    = 13  ; Get Access Point config
TOESP_MSG_AP_SET_CONFING                   = 14  ; Set Access Point config

; RND CMDS
TOESP_MSG_RND_GET_BYTE                     = 15  ; Get random byte
TOESP_MSG_RND_GET_BYTE_RANGE               = 16  ; Get random byte between custom min/max
TOESP_MSG_RND_GET_WORD                     = 17  ; Get random word
TOESP_MSG_RND_GET_WORD_RANGE               = 18  ; Get random word between custom min/max

; SERVER CMDS
TOESP_MSG_SERVER_GET_STATUS                = 19  ; Get server connection status
TOESP_MSG_SERVER_PING                      = 20  ; Get ping between ESP and server
TOESP_MSG_SERVER_SET_PROTOCOL              = 21  ; Set protocol to be used to communicate (WS/UDP)
TOESP_MSG_SERVER_GET_SETTINGS              = 22  ; Get current server host name and port
TOESP_MSG_SERVER_GET_CONFIG_SETTINGS       = 23  ; Get server host name and port defined in the Rainbow config file
TOESP_MSG_SERVER_SET_SETTINGS              = 24  ; Set current server host name and port
TOESP_MSG_SERVER_RESTORE_SETTINGS          = 25  ; Restore server host name and port to values defined in the Rainbow config
TOESP_MSG_SERVER_CONNECT                   = 26  ; Connect to server
TOESP_MSG_SERVER_DISCONNECT                = 27  ; Disconnect from server
TOESP_MSG_SERVER_SEND_MESSAGE              = 28  ; Send message to server

; NETWORK CMDS
TOESP_MSG_NETWORK_SCAN                     = 29  ; Scan networks around and return count
TOESP_MSG_NETWORK_GET_SCANNED_DETAILS      = 30  ; Get scanned network details
TOESP_MSG_NETWORK_GET_REGISTERED           = 31  ; Get registered networks status
TOESP_MSG_NETWORK_GET_REGISTERED_DETAILS   = 32  ; Get registered network SSID
TOESP_MSG_NETWORK_REGISTER                 = 33  ; Register network
TOESP_MSG_NETWORK_UNREGISTER               = 34  ; Unregister network

; FILE COMMANDS
TOESP_MSG_FILE_OPEN                        = 35  ; Open working file
TOESP_MSG_FILE_CLOSE                       = 36  ; Close working file
TOESP_MSG_FILE_STATUS                      = 37  ; Get working file status
TOESP_MSG_FILE_EXISTS                      = 38  ; Check if file exists
TOESP_MSG_FILE_DELETE                      = 39  ; Delete a file
TOESP_MSG_FILE_SET_CUR                     = 40  ; Set working file cursor position a file
TOESP_MSG_FILE_READ                        = 41  ; Read working file (at specific position)
TOESP_MSG_FILE_WRITE                       = 42  ; Write working file (at specific position)
TOESP_MSG_FILE_APPEND                      = 43  ; Append data to working file
TOESP_MSG_FILE_COUNT                       = 44  ; Count files in a specific path
TOESP_MSG_FILE_GET_LIST                    = 45  ; Get list of existing files in a path
TOESP_MSG_FILE_GET_FREE_ID                 = 46  ; Get an unexisting file ID in a specific path
TOESP_MSG_FILE_GET_INFO                    = 47  ; Get file info (size + crc32)
TOESP_MSG_FILE_DOWNLOAD                    = 48  ; Download a file from a giving URL to a specific path index / file index
TOESP_MSG_FILE_FORMAT                      = 49  ; Format file system

;-------------------------------------------------------------------------------
; Commands from ESP to NES
;-------------------------------------------------------------------------------

; ESP CMDS
FROMESP_MSG_READY                          = 0   ; ESP is ready
FROMESP_MSG_DEBUG_LEVEL                    = 1   ; Returns debug configuration
FROMESP_MSG_ESP_FIRMWARE_VERSION           = 2   ; Returns the Rainbow firmware version

; WIFI / AP CMDS
FROMESP_MSG_WIFI_STATUS                    = 3   ; Returns WiFi connection status
FROMESP_MSG_SSID                           = 4   ; WiFi/AccessPoint SSID
FROMESP_MSG_IP_ADDRESS                     = 5   ; WiFi/AccessPoint IP address
FROMESP_MSG_AP_CONFIG                      = 6   ; Returns AP config

; RND CMDS
FROMESP_MSG_RND_BYTE                       = 7   ; Returns random byte value
FROMESP_MSG_RND_WORD                       = 8   ; Returns random word value

; SERVER CMDS
FROMESP_MSG_SERVER_STATUS                  = 9   ; Returns server connection status
FROMESP_MSG_SERVER_PING                    = 10  ; Returns min, max and average round-trip time and number of lost packets
FROMESP_MSG_SERVER_SETTINGS                = 11  ; Returns server settings (host name + port)
FROMESP_MSG_MESSAGE_FROM_SERVER            = 12  ; Message from server

; NETWORK CMDS
FROMESP_MSG_NETWORK_COUNT                  = 13  ; Returns number of networks found
FROMESP_MSG_NETWORK_SCANNED_DETAILS        = 14  ; Returns details for a scanned network
FROMESP_MSG_NETWORK_REGISTERED_DETAILS     = 15  ; Returns SSID for a registered network
FROMESP_MSG_NETWORK_REGISTERED             = 16  ; Returns registered networks status

; FILE CMDS
FROMESP_MSG_FILE_STATUS                    = 17  ; Returns the working file status
FROMESP_MSG_FILE_EXISTS                    = 18  ; Returns if file exists or not
FROMESP_MSG_FILE_DELETE                    = 19  ; Returns when trying to delete a file
FROMESP_MSG_FILE_LIST                      = 20  ; Returns path file list (FILE_GET_LIST)
FROMESP_MSG_FILE_DATA                      = 21  ; Returns file data (FILE_READ)
FROMESP_MSG_FILE_COUNT                     = 22  ; Returns file count in a specific path
FROMESP_MSG_FILE_ID                        = 23  ; Returns a free file ID (FILE_GET_FREE_ID)
FROMESP_MSG_FILE_INFO                      = 24  ; Returns file info (size + CRC32) (FILE_GET_INFO)
FROMESP_MSG_FILE_DOWNLOAD                  = 25  ; Returns download result code

;-------------------------------------------------------------------------------
; Constants to be used in commands
;-------------------------------------------------------------------------------

; Server protocol
ESP_PROTOCOL_WEBSOCKET         = 0
ESP_PROTOCOL_WEBSOCKET_SECURED = 1
ESP_PROTOCOL_TCP               = 2
ESP_PROTOCOL_TCP_SECURED       = 3
ESP_PROTOCOL_UDP               = 4

; Wi-Fi status
ESP_WIFI_STATUS_IDLE_STATUS     = 0
ESP_WIFI_STATUS_NO_SSID_AVAIL   = 1
ESP_WIFI_STATUS_SCAN_COMPLETED  = 2
ESP_WIFI_STATUS_CONNECTED       = 3
ESP_WIFI_STATUS_CONNECT_FAILED  = 4
ESP_WIFI_STATUS_CONNECTION_LOST = 5
ESP_WIFI_STATUS_DISCONNECTED    = 6

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

;-------------------------------------------------------------------------------
; Rainbow registers
;-------------------------------------------------------------------------------

RAINBOW_WIFI_CONF = $4100
RAINBOW_WIFI_RX = $4101
RAINBOW_WIFI_TX = $4102
RAINBOW_WIFI_RX_DEST = $4103
RAINBOW_WIFI_TX_SOURCE = $4104

RAINBOW_CONFIGURATION = $4110
RAINBOW_MAPPER_VERSION = $4113

RAINBOW_PRG_BANKING_1 = $4120
RAINBOW_PRG_BANKING_2 = $4121
RAINBOW_PRG_BANKING_3 = $4122
RAINBOW_FPGA_WRAM_BANKING = $4123
RAINBOW_WRAM_BANKING = $4124

RAINBOW_CHR_BANKING_1 = $4130
RAINBOW_CHR_BANKING_2 = $4131
RAINBOW_CHR_BANKING_3 = $4132
RAINBOW_CHR_BANKING_4 = $4133
RAINBOW_CHR_BANKING_5 = $4134
RAINBOW_CHR_BANKING_6 = $4135
RAINBOW_CHR_BANKING_7 = $4136
RAINBOW_CHR_BANKING_8 = $4137
RAINBOW_CHR_BANKING_UPPER = $4138

RAINBOW_IRQ_LATCH = $4140
RAINBOW_IRQ_RELOAD = $4141
RAINBOW_IRQ_DISABLE = $4142
RAINBOW_IRQ_ENABLE = $4143

RAINBOW_PULSE_CHANNEL_1_CONTROL = $4150
RAINBOW_PULSE_CHANNEL_1_FREQ_LOW = $4151
RAINBOW_PULSE_CHANNEL_1_FREQ_HIGH = $4152
RAINBOW_PULSE_CHANNEL_2_CONTROL = $4153
RAINBOW_PULSE_CHANNEL_2_FREQ_LOW = $4154
RAINBOW_PULSE_CHANNEL_2_FREQ_HIGH = $4155
RAINBOW_SAW_CHANNEL_ACCUMULATOR = $4156
RAINBOW_SAW_CHANNEL_FREQ_LOW = $4157
RAINBOW_SAW_CHANNEL_FREQ_HIGH = $4158

RAINBOW_MULTIPLY_A = $4160
RAINBOW_MULTIPLY_B = $4161

;-------------------------------------------------------------------------------
; Message parsing constants
;-------------------------------------------------------------------------------

ESP_MSG_SIZE = 0
ESP_MSG_TYPE = 1
ESP_MSG_PAYLOAD = 2

;-------------------------------------------------------------------------------
; Invariable messages
;-------------------------------------------------------------------------------

esp_cmd_clear_buffers:
	.byt 1, TOESP_MSG_CLEAR_BUFFERS

esp_cmd_connect:
	.byt 1, TOESP_MSG_SERVER_CONNECT;

esp_cmd_get_esp_status:
	.byt 1, TOESP_MSG_GET_ESP_STATUS

;-------------------------------------------------------------------------------
; Utility routines
;-------------------------------------------------------------------------------

; Hardcoded position of the buffers for convenience routines
;  If you change buffers positions (RAINBOW_WIFI_RX_DEST/TX_DEST), you should update it
esp_rx_buffer = $4800
esp_tx_buffer = $4900

; Shorter call convention for esp_send_cmd
;  register A - address of the command data (lsb)
;  register X - address of the command data (msb)
;
; Overwrites all registers, tmpfield1 and tmpfield2
esp_send_cmd_short:
.(
	sta tmpfield1
	stx tmpfield2
	;rts ; Fallthrough to esp_send_cmd
.)

; Send a command to the ESP
;  tmpfield1,tmpfield2 - address of the command data
;
; Command data follows the format
;  First byte is the message length (number of bytes following this first byte).
;  Second byte is the command opcode.
;  Any remaining bytes are parameters for the command.
;
; Overwrites all registers
esp_send_cmd:
.(
	; Wait for the mapper to be ready to send a message to ESP
	jsr esp_wait_tx

	; Get length field
	ldy #0
	lda (tmpfield1), y
	tax

	; Copy message
	sta esp_tx_buffer
	copy_payload_byte:
		iny
		lda (tmpfield1), y
		sta esp_tx_buffer, y

		dex
		bne copy_payload_byte

	; Send message
	sta RAINBOW_WIFI_TX

	rts
.)

; Retrieve a message from ESP
;  tmpfield1,tmpfield2 - address where the message is stored
;
; Message data follows the format
;  First byte is the message length (number of bytes following this first byte).
;  Second byte is the message type.
;  Any remaining bytes are payload of the message.
;
; Output
;  - Retrieved message is stored at address pointed by tmpfield1,tmpfield2
;  - Y number of bytes retrieved (zero if there was no message, message length otherwise)
;
; Note
;  - Y returns the contents of the "message length" field, so it is one less than the number
;    of bytes writen in memory.
;  - First byte of destination is always written (to zero if there was no message)
;  - It is indistinguishable if there was a message with a length field of zero or there
;    was no message.
;
; Overwrites all registers
esp_get_msg:
.(
	ldy #0

	bit RAINBOW_WIFI_RX
	bmi store_msg

		; No message, set msg_len to zero
		lda #0
		sta (tmpfield1), y
		rts

	store_msg:
		; Copy message in destination buffer
		lda esp_rx_buffer
		sta (tmpfield1), y
		tax

		store_payload:
			iny
			lda esp_rx_buffer, y
			sta (tmpfield1), y

			dex
			bne store_payload

		; Acknoledge message reception
		sta RAINBOW_WIFI_RX

	rts
.)

; Wait for ESP data to be ready to read
esp_wait_answer:
.(
	wait_ready_bit:
		bit RAINBOW_WIFI_RX
		bpl wait_ready_bit
	rts
.)

; Wait for mapper to be ready to send data to esp
esp_wait_tx:
.(
	wait_ready_bit:
		bit RAINBOW_WIFI_TX
		bpl wait_ready_bit
	rts
.)
