extern printf

section .data
    enter_msg db "Enter a number (1-99): "
    enter_msg_len equ $ - enter_msg

    invalid_msg db "Invalid number! (1 <= number <= 99)", 10
    invalid_msg_len equ $ - invalid_msg

    fmt db "%d * %d = %d", 10, 0

    newline db 10
    MAX_LEN equ 10

section .bss
    r_buf resb MAX_LEN
    w_buf resb MAX_LEN

section .text
    global main

main:
    mov rdi, enter_msg
    mov rsi, enter_msg_len
    call print

    call input  
    mov r10, rax    ; r10 = input_len

    mov rdi, r_buf
    mov rsi, r10
    call is_number ; rax = true/false
    cmp rax, 0
    je print_invalid

    push rbp
    mov rbp, rsp
    mov rdi, r_buf
    mov rsi, r10
    call atoi
    mov rsp, rbp
    pop rbp

    cmp rax, 0
    je _exit

    cmp rax, 1
    jl print_invalid
    cmp rax, 99
    jg print_invalid

    mov r13, rax     ; r13 = input_number
    call print_gugudan

    jmp _exit

; print(msg, msg_len)
print:
    mov rax, 0x1        ; syscall 'write'
    mov rdx, rsi   
    mov rsi, rdi        
    mov rdi, 0x1        ; stdout
    syscall
    ret

print_invalid:
    mov rdi, invalid_msg
    mov rsi, invalid_msg_len
    call print

    jmp _exit

; print_gugudan(r9 = number)
print_gugudan:
    mov r12, 1
.loop:
    cmp r12, 10
    jge .done
    
    mov rax, r13
    imul rax, r12

    mov rdi, fmt
    mov rsi, r13
    mov rdx, r12
    mov rcx, rax
    mov rax, 0

    push r12
    call printf
    pop r12

    inc r12
    jmp .loop
.done:
    ret

input:
    mov rax, 0x0    ; syscall 'read'
    mov rdi, 0x0    ; stdin
    mov rsi, r_buf    
    mov rdx, 0xa    ; 10 bytes
    syscall
    
    cmp rax, 0
    jle .done

    ; '\n' -> 'NULL'
    cmp byte [r_buf + rax - 1], 10
    jne .done
    dec rax
    mov byte [r_buf + rax], 0     ; EOF -> BUG!!
.done:
    ret

; is_number(buf, buf_len) -> rax = true/false
is_number:
    xor rax, rax
    xor rcx, rcx
    call .loop
    ret
.loop:
    cmp rcx, rsi
    jge .return_true

    xor rbx, rbx

    mov bl, [rdi+rcx]
    cmp bl, 0x00   ; NULL
    je .return_true
    cmp bl, '0'
    jl .return_false
    cmp bl, '9'
    jg .return_false

    inc rcx
    jmp .loop
.return_true:
    mov rax, 1
    ret
.return_false:
    xor rax, rax
    ret

; atoi(buf, buf_len) -> rax = number
atoi:
    xor rax, rax    ; number
    xor rbx, rbx
    xor rcx, rcx
    call .loop    
    ret
.loop:
    cmp rcx, rsi
    jge .done

    mov bl, [rdi+rcx]
    cmp bl, 0x0
    je .done
    sub bl, '0'

    imul rax, 10
    add rax, rbx

    inc rcx
    jmp .loop
.done:
    ret

; iota(number, buf) -> rax = length
iota:
    mov rax, rdi
    mov rbx, 10
    xor rcx, rcx
.push_loop:
    xor rdx, rdx
    div rbx ; rax: 몫 / rdx:나머지
    add dl, '0'
    push rdx
    inc rcx

    cmp rax, 0
    jg .push_loop

    mov r8, rcx
    xor rdx, rdx
.pop_loop:
    pop rax
    mov [rsi + rdx], al
    inc rdx
    loop .pop_loop

    mov byte [rsi + rdx], 0
    mov rax, r8
    jmp .done
.done:
    ret

_exit:
    mov rax, 0x3c
    mov rdi, 0x0
    syscall