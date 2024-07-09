#ifndef TAGION_API_ERRORS_H
#define TAGION_API_ERRORS_H

#include <stdint.h>

// Tagion c-api error codes (equivalent to D's ErrorCode enum)
typedef enum {
  TAGION_ERROR_NONE = 0,
  TAGION_ERROR_EXCEPTION = -1,
  TAGION_ERROR_ERROR = -2
} TagionErrorCode;

void tagion_error_text(const char* msg, uint64_t* msg_len);

void tagion_clear_error();

#endif // TAGION_API_ERRORS_H
