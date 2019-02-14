DOCUMENT_ROOT_BUFFER_SIZE = 255

struc srv_config_t
{
    .port          dw 80
    .cpu_limit     db 4
    .document_root db DOCUMENT_ROOT_BUFFER_SIZE+1 dup(0)
}

