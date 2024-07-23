#include <math.h>
#include <stddef.h>
#include <stdint.h>

typedef struct SecureNet
{
    int32_t magic_byte;
    void *securenet;
} SecureNet;

int32_t tagion_generate_keypair(const char *passphrase_ptr, const uint64_t passphrase_len, const char *salt_ptr, const uint64_t salt_len, SecureNet *out_securenet, const char *const pin_ptr, const uint64_t pin_len, uint8_t **out_device_doc_ptr, uint64_t *out_device_doc_len);

int32_t tagion_decrypt_devicepin(const char *const pin_ptr, const uint64_t pin_len, uint8_t *devicepin_ptr, size_t devicepin_len, SecureNet *out_securenet);

int32_t tagion_sign_message(const SecureNet root_net, const uint8_t *const message_ptr, const uint64_t message_len, uint8_t **signature_ptr, uint64_t *signature_len);