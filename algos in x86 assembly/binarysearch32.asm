; ============================================================
; bsearch32.asm — Binary Search (signed int32_t)
; ABI: System V AMD64, NASM/Intel syntax
; long bsearch32(const int *arr, size_t n, int key); // returns index or -1
; Build: nasm -f elf64 bsearch32.asm -o bsearch32.o
; ============================================================

        default rel
        bits 64

        section .text
        global bsearch32

; ------------------------------------------------------------
; long bsearch32(const int *arr, size_t n, int key)
; RDI=arr, RSI=n, RDX=key -> RAX=index or -1
; ------------------------------------------------------------
bsearch32:
        push    rbp
        mov     rbp, rsp

        xor     r8, r8                   ; low = 0
        mov     r9, rsi
        test    r9, r9
        jz      .not_found
        dec     r9                        ; high = n-1

.loop:
        cmp     r8, r9
        jg      .not_found

        mov     rax, r9
        sub     rax, r8                   ; (high - low)
        shr     rax, 1
        add     rax, r8                   ; mid

        mov     ecx, dword [rdi + rax*4]  ; val = arr[mid]
        cmp     ecx, edx                  ; signed compare val ? key
        je      .found
        jl      .go_right                 ; val < key -> low = mid+1
        lea     r9, [rax - 1]             ; val > key -> high = mid-1
        jmp     .loop

.go_right:
        lea     r8, [rax + 1]
        jmp     .loop

.found:
        ; index already in RAX
        mov     rsp, rbp
        pop     rbp
        ret

.not_found:
        mov     rax, -1
        mov     rsp, rbp
        pop     rbp
        ret
