format ELF64 executable 3
entry main

segment readable executable

include './syscalls/io.inc'
include './syscalls/process.inc'

main:
    print started_log, started_log_size
    exit

segment readable writeable

started_log db 'server started', 0xA
started_log_size = $-started_log

include './headers/server.inc'
include './headers/content_type.inc'
