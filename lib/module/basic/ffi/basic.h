#include <stdint.h>

int32_t start_rt();

int32_t stop_rt();

int32_t tagion_basic_encode_base64url(const uint8_t* const buf_ptr, const uint64_t buf_len, char** str_ptr, uint64_t* str_len);

int32_t tagion_create_dartindex(const uint8_t* const doc_ptr, const uint64_t doc_len, uint8_t** dart_index_buf, uint64_t* dart_index_buf_len);

int32_t tagion_revision(char** str_ptr, uint64_t* str_len);