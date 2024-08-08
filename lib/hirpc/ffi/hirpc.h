#include <stdint.h>
#include <stdbool.h>

typedef struct SecureNet
{
    int32_t magic_byte;
    void *securenet;
} SecureNet;

int32_t tagion_hirpc_create_sender(
    const char *const method,
    const uint64_t method_len,
    uint8_t *param,
    const uint64_t param_len,
    uint8_t **out_doc,
    uint64_t *out_doc_len);

int32_t tagion_hirpc_create_signed_sender(
    const char *method,
    const uint64_t method_len,
    const uint8_t *param,
    const uint64_t param_len,
    const SecureNet *root_net,
    const uint8_t *deriver,
    const uint64_t deriver_len,
    uint8_t **out_doc,
    uint64_t *out_doc_len);