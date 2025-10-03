; ============================================================
; heapsort.asm — Heap Sort for int32_t arrays (signed compare)
; ABI: System V AMD64, NASM/Intel syntax
; void heapsort(int *arr, size_t n);
; Build: nasm -f elf64 heapsort.asm -o heapsort.o
; ============================================================

        default rel
        bits 64

        section .text
        global heapsort

; ------------------------------------------------------------
; void heapsort(int *arr, size_t n)
; RDI=arr, RSI=n
; ------------------------------------------------------------
heapsort:
        push    rbp
        mov     rbp, rsp

        cmp     rsi, 2                  ; n < 2 ? return
        jb      .ret

        mov     rdx, rsi
        dec     rdx                      ; end = n-1 (keep in RDX across build+extract)

        ; Build max-heap: for (i = n/2 - 1; i >= 0; --i) siftdown(arr,i,end)
        mov     rcx, rsi
        shr     rcx, 1                   ; rcx = n/2
        test    rcx, rcx
        jz      .extract
        dec     rcx                      ; i = n/2 - 1
.heap_build_loop:
        mov     rsi, rcx                 ; start = i
        call    siftdown                 ; RDI=arr, RSI=start, RDX=end
        test    rcx, rcx
        jz      .extract
        dec     rcx
        jmp     .heap_build_loop

.extract:
        ; for (end = n-1; end > 0; --end) { swap(a[0], a[end]); siftdown(a,0,end-1); }
.extract_loop:
        test    rdx, rdx                 ; while (end > 0)
        jz      .ret

        ; swap a[0] and a[end]
        mov     eax, dword [rdi]         ; eax = a[0]
        mov     r8, rdx
        shl     r8, 2                    ; r8 = end * 4
        mov     r9d, dword [rdi + r8]    ; r9d = a[end]
        mov     dword [rdi], r9d
        mov     dword [rdi + r8], eax

        ; siftdown(a, 0, end-1)
        mov     rsi, 0
        mov     rax, rdx
        dec     rax
        mov     rdx, rax                 ; end = end-1 for siftdown
        call    siftdown

        dec     rdx                      ; end--
        jmp     .extract_loop

.ret:
        mov     rsp, rbp
        pop     rbp
        ret

; ------------------------------------------------------------
; static void siftdown(int *arr, size_t start, size_t end)
; RDI=arr, RSI=root, RDX=end
; ------------------------------------------------------------
siftdown:
        push    rbp
        mov     rbp, rsp

        mov     r8, rsi                  ; r8 = root
.sift_loop:
        lea     r9, [r8*2 + 1]           ; child = 2*root + 1
        cmp     r9, rdx
        ja      .done                    ; no children

        mov     r10, r8                  ; swapIdx = root

        ; if a[swapIdx] < a[child] swapIdx = child
        mov     eax, dword [rdi + r10*4]
        mov     edx, dword [rdi + r9*4]
        cmp     eax, edx
        jge     .check_right
        mov     r10, r9

.check_right:
        lea     rcx, [r9 + 1]            ; right child
        cmp     rcx, rdx
        ja      .maybe_swap

        mov     eax, dword [rdi + r10*4]
        mov     edx, dword [rdi + rcx*4]
        cmp     eax, edx
        jge     .maybe_swap
        mov     r10, rcx

.maybe_swap:
        cmp     r10, r8
        je      .done

        ; swap a[root], a[swapIdx]
        mov     eax, dword [rdi + r8*4]
        mov     edx, dword [rdi + r10*4]
        mov     dword [rdi + r8*4], edx
        mov     dword [rdi + r10*4], eax

        mov     r8, r10
        jmp     .sift_loop

.done:
        mov     rsp, rbp
        pop     rbp
        ret
