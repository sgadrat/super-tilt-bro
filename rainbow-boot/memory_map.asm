; Global variables used in boot code
; Note, this file relies on "mem_labels.asm" to contain c registers at the begining of zero page, but boot code must be be completely independent
; so evertyhing that is not C registers in "mem_labels.asm" should ideally not be defined. (It is not the case because, by the force of things,
; having differings C registers locations.)

.(
cursor = last_c_label + 1

+crc32_value = cursor : -cursor += 4
+crc32_address = cursor : -cursor += 2

+log_position = cursor : -cursor += 1
+scroll_state = cursor : -cursor += 1
.)
