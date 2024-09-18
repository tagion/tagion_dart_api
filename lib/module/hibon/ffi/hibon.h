#include <stdint.h>
#include <stdbool.h>

typedef struct HiBONT
{
    int32_t magic_byte;
    void *hibon;
} HiBONT;

int32_t tagion_hibon_create(HiBONT *instance);

void tagion_hibon_free(HiBONT *instance);

int32_t tagion_hibon_get_text(const HiBONT *const instance, int32_t text_format, char **str, uint64_t *str_len);

int32_t tagion_hibon_get_document(const HiBONT *const instance, uint8_t **buf, uint64_t *buf_len);

int32_t tagion_hibon_add_string(const HiBONT *const instance, const char *const key, const uint64_t key_len, const char *const value, const uint64_t value_len);

int32_t tagion_hibon_add_document(const HiBONT *const instance, const char *const key, const uint64_t key_len, const uint8_t *const buf, const uint64_t buf_len);

int32_t tagion_hibon_add_index_document(const HiBONT *const instance, const int32_t index, const uint8_t *const buf, const uint64_t buf_len);

int32_t tagion_hibon_add_hibon(const HiBONT *const instance, const char *const key, const uint64_t key_len, const HiBONT *const sub_instance);

int32_t tagion_hibon_add_index_hibon(const HiBONT *const instance, const int32_t index, const HiBONT *const sub_instance);

int32_t tagion_hibon_add_binary(const HiBONT *const instance, const char *const key, const uint64_t key_len, const uint8_t *const buf, const uint64_t buf_len);

int32_t tagion_hibon_add_index_binary(const HiBONT *const instance, const int32_t index, const uint8_t *const buf, const uint64_t buf_len);

int32_t tagion_hibon_add_time(const HiBONT *const instance, const char *const key, const uint64_t key_len, const int64_t time);

int32_t tagion_hibon_add_bool(const HiBONT *const h, const char *const key, const uint64_t key_len, bool value);

int32_t tagion_hibon_add_int32(const HiBONT *const h, const char *const key, const uint64_t key_len, int32_t value);

int32_t tagion_hibon_add_int64(const HiBONT *const h, const char *const key, const uint64_t key_len, int64_t value);

int32_t tagion_hibon_add_uint32(const HiBONT *const h, const char *const key, const uint64_t key_len, uint32_t value);

int32_t tagion_hibon_add_uint64(const HiBONT *const h, const char *const key, const uint64_t key_len, uint64_t value);

int32_t tagion_hibon_add_float32(const HiBONT *const h, const char *const key, const uint64_t key_len, float value);

int32_t tagion_hibon_add_float64(const HiBONT *const h, const char *const key, const uint64_t key_len, double value);

int32_t tagion_hibon_has_member(const HiBONT *const h, const char *const key, const uint64_t key_len, bool *result);

int32_t tagion_hibon_has_member_index(const HiBONT *const h, const int32_t index, bool *result);

int32_t tagion_hibon_remove_by_key(const HiBONT *const h, const char *const key, const uint64_t key_len);

int32_t tagion_hibon_remove_by_index(const HiBONT *const h, const int32_t index);