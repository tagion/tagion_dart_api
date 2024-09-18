#include <stdint.h>
#include <stdbool.h>

typedef struct Element
{
    uint8_t *data;
} Element;

int32_t tagion_document_element_by_key(const uint8_t* const buf, const uint64_t buf_len, const char* const key, const uint64_t key_len, Element* element);

int32_t tagion_document_get_version(const uint8_t *const buf, const uint64_t buf_len, uint32_t *ver);

int32_t tagion_document_get_record_name(const uint8_t *const buf, const uint64_t buf_len, char **record_name, uint64_t *record_name_len);

int32_t tagion_document_valid(const uint8_t *const buf, const uint64_t buf_len, int32_t *error_code);

int32_t tagion_document_element_by_index(const uint8_t* const buf, const uint64_t buf_len, const uint64_t index, Element* element);

int32_t tagion_document_get_text(const uint8_t *const buf, const uint64_t buf_len, const int32_t text_format, char **str, uint64_t *str_len);

int32_t tagion_document_get_document(const Element *const element, uint8_t **buf, uint64_t *buf_len);

int32_t tagion_document_get_string(const Element *const element, char **value, uint64_t *str_len);

int32_t tagion_document_get_u8_array(Element* const element, uint8_t** buf, uint64_t* buf_len);

int32_t tagion_document_get_time(const Element *const element, int64_t *time);

int32_t tagion_document_get_bigint(const Element *const element, uint8_t **bigint_buf, uint64_t *bigint_buf_len);

int32_t tagion_document_get_bool(const Element *const element, bool *value);

int32_t tagion_document_get_int32(const Element *const element, int32_t *value);

int32_t tagion_document_get_int64(const Element *const element, int64_t *value);

int32_t tagion_document_get_uint32(const Element *const element, uint32_t *value);

int32_t tagion_document_get_uint64(const Element *const element, uint64_t *value);

int32_t tagion_document_get_float32(const Element *const element, float *value);

int32_t tagion_document_get_float64(const Element *const element, double *value);
