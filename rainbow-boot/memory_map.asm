; Global variables used in boot code

.(
cursor = last_c_label + 1

+crc32_value = cursor : -cursor += 4
+crc32_address = cursor : -cursor += 2

+log_position = cursor : -cursor += 1
+scroll_state = cursor : -cursor += 1
.)
