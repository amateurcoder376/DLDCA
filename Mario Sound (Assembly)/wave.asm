section .data
    sample_rate dq 44100
    amplitude dq 30000

section .text

global generate_wave

generate_wave:
    push rbp
    
    push rbx
    push r12
    push r13
    push r14
    push r15

    ;rdi = buffer
    ;rsi = frames
    ;rdx = frequency
    sub rsp, 24
    mov [rsp], rdi ;buffer
    mov [rsp+8], rsi ;frames
    mov [rsp+16], rdx ;frequency

    mov rax, [rsp+16]
    cmp rax, 0

    je .firstEqual

.notFirstEqual:

    mov rax, [rel sample_rate]
    mov rcx, [rsp+16]
    imul rcx, 2
    xor rdx, rdx
    div rcx ;rax=halfPeriod

    mov r12, rax ;r12=halfperiod
    mov r13, rax ;r13=counter

    mov r14, [rel amplitude] ;r14=sample

    sub rsp, 24
    mov [rsp], r12 ;halfperiod
    mov [rsp+8], r13 ;counter
    mov [rsp+16], r14 ;sample

    sub rsp, 8
    mov r12, 0 ;r12=initial i
    mov [rsp], r12 ; i


    .forSecondBegin:
        mov rax, [rsp] ; i
        mov rbx, [rsp+40] ;frames
        cmp rax, rbx
        jge .forSecondEnd

        mov rax, [rsp+32] ;rax=buffer
        mov rbx, [rsp] ;i
        mov r12, [rsp+24] ;sample

        mov word [rax+rbx*2], r12w ;buffer[i]=sample

        mov rax, [rsp+16]
        sub rax, 1
        mov [rsp+16], rax ;counter--

        mov rax, [rsp+16] ;counter
        cmp rax, 0
        jg .notlessthanequalzero
        mov rax, [rsp+24]
        imul rax, -1
        mov [rsp+24], rax ;sample=-sample

        mov rax, [rsp+16] ;counter
        mov rbx, [rsp+8] ;halfperiod

        mov rax, rbx
        mov [rsp+16], rax ;counter = halfperiod


        .notlessthanequalzero:
        mov rax, [rsp]
        add rax, 1
        mov [rsp], rax ;i++
        jmp .forSecondBegin


    .forSecondEnd:
        add rsp, 32
        jmp .return



.firstEqual:
    mov rax, 0 ;rax=initial i
    sub rsp, 8
    mov [rsp], rax ;[rsp]=i
    .forBeginInEqual:
        mov rax, [rsp]
        mov rbx, [rsp+16]
        cmp rax, rbx
        jge .forEndFirst
        mov rax, [rsp+8] ;buffer
        mov rbx, [rsp] ;i
        mov word [rax+2*rbx], 0

        mov rax, [rsp]
        add rax, 1
        mov [rsp], rax ;i++
        jmp .forBeginInEqual

    .forEndFirst:
        add rsp, 8
        jmp .return
.return:
    add rsp, 24

    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    
    pop rbp
    ret