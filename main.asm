format ELF64 executable 3
entry main

segment readable executable

include './syscalls/io.inc'
include './syscalls/process.inc'

main:
    fork
    cmp rax, -1
    jne fork_success

fork_fail:
    print fork_fail_log, fork_fail_log_size
    exit_error

fork_success:
    cmp rax, 0
    jne worker_process
    jmp master_process

master_process:
    print master_log, master_log_size
    exit_ok

worker_process:
    print worker_log, worker_log_size
    exit_ok

segment readable writeable

fork_fail_log db 'fork failed', 0xA
fork_fail_log_size = $-fork_fail_log

master_log db 'master process', 0xA
master_log_size = $-master_log

worker_log db 'worker process', 0xA
worker_log_size = $-worker_log

include './headers/server.inc'
include './headers/content_type.inc'
