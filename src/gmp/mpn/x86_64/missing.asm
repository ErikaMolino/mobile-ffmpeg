
	dnl  AMD64 MULX/ADX simulation support.

dnl  Contributed to the GNU project by Torbjörn Granlund.

dnl  Copyright 2013 Free Software Foundation, Inc.

dnl  This file is part of the GNU MP Library.
dnl
dnl  The GNU MP Library is free software; you can redistribute it and/or modify
dnl  it under the terms of either:
dnl
dnl    * the GNU Lesser General Public License as published by the Free
dnl      Software Foundation; either version 3 of the License, or (at your
dnl      option) any later version.
dnl
dnl  or
dnl
dnl    * the GNU General Public License as published by the Free Software
dnl      Foundation; either version 2 of the License, or (at your option) any
dnl      later version.
dnl
dnl  or both in parallel, as here.
dnl
dnl  The GNU MP Library is distributed in the hope that it will be useful, but
dnl  WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
dnl  or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
dnl  for more details.
dnl
dnl  You should have received copies of the GNU General Public License and the
dnl  GNU Lesser General Public License along with the GNU MP Library.  If not,
dnl  see https://www.gnu.org/licenses/.


include(`../config.m4')

ASM_START()

C Fake the MULX instruction
C
C Accept the single explicit parameter on the stack, return the two result
C words on the stack.  This calling convention means that we need to move the
C return address up.
C
PROLOGUE(__gmp_mulx)
	lea	-8(%rsp), %rsp
	push	%rax
	push	%rdx
	pushfq				C preserve all flags
	mov	32(%rsp), %rax		C move retaddr...
	mov	%rax, 24(%rsp)		C ...up the stack
	mov	40(%rsp), %rax		C input parameter
	mul	%rdx
	mov	%rax, 32(%rsp)
	mov	%rdx, 40(%rsp)
	popfq				C restore eflags
	pop	%rdx
	pop	%rax
	ret
EPILOGUE()
PROTECT(__gmp_mulx)


C Fake the ADOX instruction
C
C Accept the two parameters on the stack, return the result word on the stack.
C This calling convention means that we need to move the return address down.
C
PROLOGUE(__gmp_adox)
	push	%rcx
	push	%rbx
	push	%rax
	mov	32(%rsp), %rcx		C src2
	mov	24(%rsp), %rax		C move retaddr...
	mov	%rax, 32(%rsp)		C ...down the stack
	pushfq
C copy 0(%rsp):11 to 0(%rsp):0
	mov	(%rsp), %rbx
	shr	%rbx
	bt	$10, %rbx
	adc	%rbx, %rbx
	push	%rbx
C put manipulated flags into eflags, execute a plain adc
	popfq
	adc	%rcx, 48(%rsp)
C copy CF to 0(%rsp):11
	pop	%rbx
	sbb	R32(%rax), R32(%rax)
	and	$0x800, R32(%rax)
	and	$0xfffffffffffff7ff, %rbx
	or	%rax, %rbx
	push	%rbx
C put manipulated flags into eflags
	popfq
	pop	%rax
	pop	%rbx
	pop	%rcx
	lea	8(%rsp), %rsp
	ret
EPILOGUE()
PROTECT(__gmp_adox)


C Fake the ADCX instruction
C
C Accept the two parameters on the stack, return the result word on the stack.
C This calling convention means that we need to move the return address down.
C
PROLOGUE(__gmp_adcx)
	push	%rcx
	push	%rbx
	push	%rax
	mov	32(%rsp), %rcx		C src2
	mov	24(%rsp), %rax		C move retaddr...
	mov	%rax, 32(%rsp)		C ...down the stack
	pushfq
	adc	%rcx, 48(%rsp)
	pop	%rbx
	sbb	R32(%rax), R32(%rax)
	and	$`'0xfffffffffffffffe, %rbx
	sub	%rax, %rbx
	push	%rbx
	popfq
	pop	%rax
	pop	%rbx
	pop	%rcx
	lea	8(%rsp), %rsp
	ret
EPILOGUE()
PROTECT(__gmp_adcx)
