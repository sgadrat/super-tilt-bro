TOESP_MSG_GET_ESP_STATUS = 0          ; Get ESP status
TOESP_MSG_DEBUG_LOG = 1               ; Debug / Log data
TOESP_MSG_CLEAR_BUFFERS = 2           ; Clear RX/TX buffers
TOESP_MSG_E2N_BUFFER_DROP = 3         ; Drop messages from TX (ESP->NES) buffer
TOESP_MSG_GET_WIFI_STATUS = 4         ; Get WiFi connection status
TOESP_MSG_GET_RND_BYTE = 5            ; Get random byte
TOESP_MSG_GET_RND_BYTE_RANGE = 6      ; Get random byte between custom min/max
TOESP_MSG_GET_RND_WORD = 7            ; Get random word
TOESP_MSG_GET_RND_WORD_RANGE = 8      ; Get random word between custom min/max
TOESP_MSG_GET_SERVER_STATUS = 9       ; Get server connection status
TOESP_MSG_GET_SERVER_PING = 10        ; Get ping between ESP and server
TOESP_MSG_SET_SERVER_PROTOCOL = 11    ; Set protocol to be used to communicate (WS/UDP)
TOESP_MSG_GET_SERVER_SETTINGS = 12    ; Get host name and port defined in the ESP config
TOESP_MSG_SET_SERVER_SETTINGS = 13    ; Set host name and port
TOESP_MSG_CONNECT_TO_SERVER = 14      ; Connect to server
TOESP_MSG_DISCONNECT_FROM_SERVER = 15 ; Disconnect from server
TOESP_MSG_SEND_MESSAGE_TO_SERVER = 16 ; Send message to rainbow server
TOESP_MSG_FILE_OPEN = 17              ; Open working file
TOESP_MSG_FILE_CLOSE = 18             ; Close working file
TOESP_MSG_FILE_EXISTS = 19            ; Check if file exists
TOESP_MSG_FILE_DELETE = 20            ; Delete a file
TOESP_MSG_FILE_SET_CUR = 21           ; Set working file cursor position a file
TOESP_MSG_FILE_READ = 22              ; Read working file (at specific position)
TOESP_MSG_FILE_WRITE = 23             ; Write working file (at specific position)
TOESP_MSG_FILE_APPEND = 24            ; Append data to working file
TOESP_MSG_FILE_COUNT = 25             ; Count files in a specific path
TOESP_MSG_FILE_GET_LIST = 26          ; Get list of existing files in a path
TOESP_MSG_FILE_GET_FREE_ID = 27       ; Get an unexisting file ID in a specific path
TOESP_MSG_FILE_GET_INFO = 28          ; Get file info (size + crc32)

FROMESP_MSG_READY = 0                 ; ESP is ready
FROMESP_MSG_FILE_EXISTS = 1           ; Returns if file exists or not
FROMESP_MSG_FILE_DELETE = 2           ; Returns when trying to delete a file
FROMESP_MSG_FILE_LIST = 3             ; Returns path file list (FILE_GET_LIST)
FROMESP_MSG_FILE_DATA = 4             ; Returns file data (FILE_READ)
FROMESP_MSG_FILE_COUNT = 5            ; Returns file count in a specific path
FROMESP_MSG_FILE_ID = 6               ; Returns a free file ID (FILE_GET_FREE_ID)
FROMESP_MSG_FILE_INFO = 7             ; Returns file info (size + CRC32) (FILE_GET_INFO)
FROMESP_MSG_WIFI_STATUS = 8           ; Returns WiFi connection status
FROMESP_MSG_SERVER_STATUS = 9         ; Returns server connection status
FROMESP_MSG_SERVER_PING = 10          ; Returns min, max and average round-trip time and number of lost packets
FROMESP_MSG_HOST_SETTINGS = 11        ; Returns server settings (host name + port)
FROMESP_MSG_RND_BYTE = 12             ; Returns random byte value
FROMESP_MSG_RND_WORD = 13             ; Returns random word value
FROMESP_MSG_MESSAGE_FROM_SERVER = 14  ; Message from server

ESP_FILE_PATH_SAVE = 0
ESP_FILE_PATH_ROMS = 1
ESP_FILE_PATH_USER = 2

ESP_PROTOCOL_WEBSOCKET = 0
ESP_PROTOCOL_UDP = 1

RAINBOW_DATA = $5000
RAINBOW_FLAGS = $5001

; Send a command to the ESP
;  tmpfield1,tmpfield2 - address of the command data
;
; Command data follows the format
;  First byte is the message length (number of bytes following this first byte).
;  Second byte is the command opcode.
;  Any remaining byte are parameters for the command.
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
