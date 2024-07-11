#ifndef TAGION_API_ERRORS_H
#define TAGION_API_ERRORS_H

#include <stdint.h>

void tagion_error_text(const char* msg, uint64_t* msg_len);

void tagion_clear_error();

#endif // TAGION_API_ERRORS_H
