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

+flash_operation_status = cursor : -cursor += 4
+flash_operation_address = cursor : -cursor += 1
+erase_sector_result = cursor : -cursor += 1
+program_page_result_flags = cursor : -cursor += 1
+program_page_result_count = cursor : -cursor += 1

+hfm_data_stream_index = cursor : -cursor += 2
+decompress_page_result = cursor : -cursor += 1
+decompress_current_byte = cursor : -cursor += 1
+huffmunch_zpblock = cursor : -cursor += 9

#if cursor > $ff
#print cursor
#error no more space in zero page
#endif

+program_data = $0200
+flash_code_ram = $0300
.)
