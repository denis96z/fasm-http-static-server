DEFAULT_SERVER_PORT = 80
DEFAULT_NUM_WORKERS = 2
DEFAULT_MAX_CONNECTIONS = 1024
DOCUMENT_ROOT_BUFFER_SIZE = 255

struc srv_config_t
{
    .port            dw 0x5000 ;80
    .num_workers     dq DEFAULT_NUM_WORKERS
    .document_root   db DOCUMENT_ROOT_BUFFER_SIZE+1 dup(0)
}

macro hton _port_
{
    rol _port_, 8
}
