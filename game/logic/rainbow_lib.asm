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
TOESP_MSG_GET_WIFI_STATUS                  = 6   ; Get WiFi connection status
TOESP_MSG_ESP_RESTART                      = 7   ; Restart ESP

; RND CMDS
TOESP_MSG_RND_GET_BYTE                     = 8   ; Get random byte
TOESP_MSG_RND_GET_BYTE_RANGE               = 9   ; Get random byte between custom min/max
TOESP_MSG_RND_GET_WORD                     = 10  ; Get random word
TOESP_MSG_RND_GET_WORD_RANGE               = 11  ; Get random word between custom min/max

; SERVER CMDS
TOESP_MSG_SERVER_GET_STATUS                = 12  ; Get server connection status
TOESP_MSG_SERVER_PING                      = 13  ; Get ping between ESP and server
TOESP_MSG_SERVER_SET_PROTOCOL              = 14  ; Set protocol to be used to communicate (WS/UDP)
TOESP_MSG_SERVER_GET_SETTINGS              = 15  ; Get current server host name and port
TOESP_MSG_SERVER_GET_CONFIG_SETTINGS       = 16  ; Get server host name and port defined in the Rainbow config file
TOESP_MSG_SERVER_SET_SETTINGS              = 17  ; Set current server host name and port
TOESP_MSG_SERVER_RESTORE_SETTINGS          = 18  ; Restore server host name and port to values defined in the Rainbow config
TOESP_MSG_SERVER_CONNECT                   = 19  ; Connect to server
TOESP_MSG_SERVER_DISCONNECT                = 20  ; Disconnect from server
TOESP_MSG_SERVER_SEND_MESSAGE              = 21  ; Send message to server

; NETWORK CMDS
TOESP_MSG_NETWORK_SCAN                     = 22  ; Scan networks around and return count
TOESP_MSG_NETWORK_GET_SCANNED_DETAILS      = 23  ; Get scanned network details
TOESP_MSG_NETWORK_GET_REGISTERED           = 24  ; Get registered networks status
TOESP_MSG_NETWORK_GET_REGISTERED_DETAILS   = 25  ; Get registered network SSID
TOESP_MSG_NETWORK_REGISTER                 = 26  ; Register network
TOESP_MSG_NETWORK_UNREGISTER               = 27  ; Unregister network

; FILE COMMANDS
TOESP_MSG_FILE_OPEN                        = 28  ; Open working file
TOESP_MSG_FILE_CLOSE                       = 29  ; Close working file
TOESP_MSG_FILE_STATUS                      = 30  ; Get working file status
TOESP_MSG_FILE_EXISTS                      = 31  ; Check if file exists
TOESP_MSG_FILE_DELETE                      = 32  ; Delete a file
TOESP_MSG_FILE_SET_CUR                     = 33  ; Set working file cursor position a file
TOESP_MSG_FILE_READ                        = 34  ; Read working file (at specific position)
TOESP_MSG_FILE_WRITE                       = 35  ; Write working file (at specific position)
TOESP_MSG_FILE_APPEND                      = 36  ; Append data to working file
TOESP_MSG_FILE_COUNT                       = 37  ; Count files in a specific path
TOESP_MSG_FILE_GET_LIST                    = 38  ; Get list of existing files in a path
TOESP_MSG_FILE_GET_FREE_ID                 = 39  ; Get an unexisting file ID in a specific path
TOESP_MSG_FILE_GET_INFO                    = 40  ; Get file info (size + crc32)
TOESP_MSG_FILE_DOWNLOAD                    = 41  ; Download a file from a giving URL to a specific path index / file index
TOESP_MSG_FILE_FORMAT                      = 42  ; Format file system

;-------------------------------------------------------------------------------
; Commands from ESP to NES
;-------------------------------------------------------------------------------

; ESP CMDS
FROMESP_MSG_READY                          = 0   ; ESP is ready
FROMESP_MSG_DEBUG_LEVEL                    = 1   ; Returns debug configuration
FROMESP_MSG_WIFI_STATUS                    = 2   ; Returns WiFi connection status

; RND CMDS
FROMESP_MSG_RND_BYTE                       = 3   ; Returns random byte value
FROMESP_MSG_RND_WORD                       = 4   ; Returns random word value

; SERVER CMDS
FROMESP_MSG_SERVER_STATUS                  = 5   ; Returns server connection status
FROMESP_MSG_SERVER_PING                    = 6   ; Returns min, max and average round-trip time and number of lost packets
FROMESP_MSG_SERVER_SETTINGS                = 7   ; Returns server settings (host name + port)
FROMESP_MSG_MESSAGE_FROM_SERVER            = 8   ; Message from server

; NETWORK CMDS
FROMESP_MSG_NETWORK_COUNT                  = 9   ; Returns number of networks found
FROMESP_MSG_NETWORK_SCANNED_DETAILS        = 10  ; Returns details for a scanned network
FROMESP_MSG_NETWORK_REGISTERED_DETAILS     = 11  ; Returns SSID for a registered network
FROMESP_MSG_NETWORK_REGISTERED             = 12  ; Returns registered networks status

; FILE CMDS
FROMESP_MSG_FILE_STATUS                    = 13  ; Returns the working file status
FROMESP_MSG_FILE_EXISTS                    = 14  ; Returns if file exists or not
FROMESP_MSG_FILE_DELETE                    = 15  ; Returns when trying to delete a file
FROMESP_MSG_FILE_LIST                      = 16  ; Returns path file list (FILE_GET_LIST)
FROMESP_MSG_FILE_DATA                      = 17  ; Returns file data (FILE_READ)
FROMESP_MSG_FILE_COUNT                     = 18  ; Returns file count in a specific path
FROMESP_MSG_FILE_ID                        = 19  ; Returns a free file ID (FILE_GET_FREE_ID)
FROMESP_MSG_FILE_INFO                      = 20  ; Returns file info (size + CRC32) (FILE_GET_INFO)
FROMESP_MSG_FILE_DOWNLOAD                  = 21  ; Returns download result code

;-------------------------------------------------------------------------------
; Constants to be used in commands
;-------------------------------------------------------------------------------

; Filesystem directories
ESP_FILE_PATH_SAVE = 0
ESP_FILE_PATH_ROMS = 1
ESP_FILE_PATH_USER = 2

; File open options
ESP_FILE_MODE_AUTO = %00000000
ESP_FILE_MODE_MANUAL = %00000001

; Server protocol
ESP_PROTOCOL_WEBSOCKET         = 0
ESP_PROTOCOL_WEBSOCKET_SECURED = 1
ESP_PROTOCOL_TCP               = 2
ESP_PROTOCOL_TCP_SECURED       = 3
ESP_PROTOCOL_UDP               = 4

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

RAINBOW_DATA = $5000
RAINBOW_FLAGS = $5001
RAINBOW_PRG_BANKING_1 = $5002
RAINBOW_PRG_BANKING_2 = $5003
RAINBOW_PRG_BANKING_3 = $5004
RAINBOW_WRAM_BANKING = $5005
RAINBOW_CONFIGURATION = $5006
RAINBOW_CHR_BANKING_UPPER = 5007
RAINBOW_CHR_BANKING_1 = $5400
RAINBOW_CHR_BANKING_2 = $5401
RAINBOW_CHR_BANKING_3 = $5402
RAINBOW_CHR_BANKING_4 = $5403
RAINBOW_CHR_BANKING_5 = $5404
RAINBOW_CHR_BANKING_6 = $5405
RAINBOW_CHR_BANKING_7 = $5406
RAINBOW_CHR_BANKING_8 = $5407
RAINBOW_PULSE_CHANNEL_1_CONTROL = $5800
RAINBOW_PULSE_CHANNEL_1_FREQ_LOW = $5801
RAINBOW_PULSE_CHANNEL_1_FREQ_HIGH = $5802
RAINBOW_PULSE_CHANNEL_2_CONTROL = $5803
RAINBOW_PULSE_CHANNEL_2_FREQ_LOW = $5804
RAINBOW_PULSE_CHANNEL_2_FREQ_HIGH = $5805
RAINBOW_SAW_CHANNEL_FREQ_LOW = $5c01
RAINBOW_SAW_CHANNEL_FREQ_HIGH = $5c02
RAINBOW_MAPPER_VERSION = $5c03
RAINBOW_IRQ_LATCH = $5c04
RAINBOW_IRQ_RELOAD = $5c05
RAINBOW_IRQ_DISABLE = $5c06
RAINBOW_IRQ_ENABLE = $5c07

;-------------------------------------------------------------------------------
; Invariable messages
;-------------------------------------------------------------------------------

esp_cmd_clear_buffers:
	.byt 1, TOESP_MSG_CLEAR_BUFFERS

esp_cmd_get_esp_status:
	.byt 1, TOESP_MSG_GET_ESP_STATUS

;-------------------------------------------------------------------------------
; Utility routines
;-------------------------------------------------------------------------------

; Shorter call convetion for esp_send_cmd
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
	ldy #0
	lda (tmpfield1), y
	sta RAINBOW_DATA

	tax
	iny
	copy_one_byte:
		lda (tmpfield1), y
		sta RAINBOW_DATA
		iny
		dex
		bne copy_one_byte

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

	bit RAINBOW_FLAGS
	bmi store_msg

		; No message, set msg_len to zero
		lda #0
		sta (tmpfield1), y
		jmp end

	store_msg:
		lda RAINBOW_DATA ; Garbage byte
		nop
		lda RAINBOW_DATA ; Message length
		sta (tmpfield1), y

		tax
		inx
		copy_one_byte:
			dex
			beq end

			iny
			lda RAINBOW_DATA
			sta (tmpfield1), y

			jmp copy_one_byte

	end:
	rts
.)

; Wait for ESP data to be ready to read
esp_wait_answer:
.(
	wait_ready_bit:
		bit RAINBOW_FLAGS
		bpl wait_ready_bit
	rts
.)
