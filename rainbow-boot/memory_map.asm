; Global variables used in boot code

.(
cursor = last_c_label + 1

+crc32_value = cursor : -cursor += 4
+crc32_address = cursor : -cursor += 2

+log_position = cursor : -cursor += 1
+rescue_controller_a_btns = cursor : -cursor += 1
+rescue_controller_b_btns = cursor : -cursor += 1
+scroll_state = cursor : -cursor += 1
+txtx = cursor : -cursor += 1
+txty = cursor : -cursor += 1

+erase_sector_status = cursor : -cursor += 3
+erase_sector_result = cursor : -cursor += 1
.)
