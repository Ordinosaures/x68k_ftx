*==========================================================================
*                 �e�L�X�g�v���[���t�H���g�\���V�X�e�� FTX
*                          ver 2.01     by �������
*==========================================================================

	.globl	_ftx_pcgdat_set
	.globl	_ftx_fnt8_put
	.globl	_ftx_fnt16_put
	.globl	_ftx_clr
	.globl	_ftx_scroll_set
	.globl	_ftx_palette_set
	.globl	_ftx_fnt16_cnv


	.include doscall.mac
	.include iocscall.mac


*==========================================================================
*
*	�X�^�b�N�t���[���̍쐬
*
*==========================================================================

	.offset 0

arg1_l	ds.b	2
arg1_w	ds.b	1
arg1_b	ds.b	1

arg2_l	ds.b	2
arg2_w	ds.b	1
arg2_b	ds.b	1

arg3_l	ds.b	2
arg3_w	ds.b	1
arg3_b	ds.b	1

arg4_l	ds.b	2
arg4_w	ds.b	1
arg4_b	ds.b	1

arg5_l	ds.b	2
arg5_w	ds.b	1
arg5_b	ds.b	1

arg6_l	ds.b	2
arg6_w	ds.b	1
arg6_b	ds.b	1


	.text
	.even


*==========================================================================
*
* �����F
*	void ftx_pcgdat_set(short *pcg_dat);
*
* �����F
*	pcg_dat :
*		CVFNT.x �ō쐬�����t�H���g PCG �f�[�^�̃|�C���^�B
*
*==========================================================================

_ftx_pcgdat_set

A7ID	=	4			*   �X�^�b�N�� return��A�h���X  [ 4 byte ]
					* + �ޔ����W�X�^�̑S�o�C�g��     [ 0 byte ]

	move.l	A7ID+arg1_l(sp),pcg_adr	* PCG �A�h���X
	rts



*==========================================================================
*
* �����F
*	void ftx_fnt8_put(short x, short y, short cd);
*
* �����F
*	x :
*		�\���� x ���W�i0�`127�j
*	y :
*		�\���� y ���W�i0�`127�j
*	cd :
*		�\������e�L�X�g PCG �i���o�[�i0�`65535�j
*
*==========================================================================

_ftx_fnt8_put

A7ID	=	4			*   �X�^�b�N�� return��A�h���X  [ 4 byte ]
					* + �ޔ����W�X�^�̑S�o�C�g��     [ 0 byte ]

	*=====[ �X�[�p�[�o�C�U���[�h�� ]
		suba.l	a1,a1
		iocs	_B_SUPER	* �X�[�p�[�o�C�U���[�h��
		move.l	d0,usp_bak	* ���X�X�[�p�[�o�C�U���[�h�̏ꍇ�� d0.l=-1


	*=====[ �����A�h���X�v�Z ]
		*-----[ GET �A�h���X ]
						* �p�^�[���z��� bg_put �R���p�`�Ƃ���

		move.l	A7ID+arg3_l(sp),d0	* d0.l = �p�^�[���R�[�h
		move.w	d0,d1			* d1.w = d0 (�o�b�N�A�b�v)

		lsr.l	#2,d0			* d0.l = �p�^�[���R�[�h / 4
		lsl.l	#7,d0			* d0.l = (�p�^�[���R�[�h / 4) * 128

		andi.w	#3,d1			* d1.w = �p�^�[���R�[�h & 3
		lsl.w	#4,d1			* d1.w = (�p�^�[���R�[�h & 3) * 16

		cmpi.w	#32,d1
		blt.b	@F			* 32 > d1 �Ȃ� bra
			subi.w	#31,d1
		@@:

		movea.l	pcg_adr(pc),a0		* a0.l = PCG �f�[�^�̃A�h���X
		adda.l	d0,a0			* a0.l += d0.l
		adda.w	d1,a0			* a0.l += d1.w
						* a0.l = PCG �ǂݏo���J�n�A�h���X

		*-----[ PUT �A�h���X ]
		movea.l	#$E00000,a1		* a1.l = T0 �� �J�n�A�h���X
		move.w	A7ID+arg1_w(sp),d0	* d0.w = x
		andi.w	#127,d0			* d0.w = x & 127
		adda.w	d0,a1			* a1.l += d0.w

		move.w	A7ID+arg2_w(sp),d0	* d0.w = y
		andi.l	#127,d0			* d0.l = y & 127
						*	PCG 1 �� Y ���� 8 �h�b�g
						*	TEXT ��� Y ���� 1 �h�b�g������ 128 �o�C�g
						*	8 * 128 = 1 << 10 �Ȃ̂ŁA10 �r�b�g�̍��V�t�g���K�v�B
						*	�����O�T�C�Y�� 10 �r�b�g�̍��V�t�g��
						*	8+2n = 28 �N���b�N������B
						*	������ swap �ƉE 6 �r�b�g�V�t�g���p�������������ŁA
						*	���v 4+20 = 24 �N���b�N�ōςށB
		swap	d0			* 4 �N���b�N
		lsr.l	#6,d0			* 8+2n (=20 �N���b�N)
		adda.l	d0,a1			* a1.l += d0.l
						* a1.l = TEXT ��� PUT ��A�h���X


	*=====[ FONT PUT ]
						* a0.l = PCG �ǂݏo���J�n�A�h���X
						* a1.l = TEXT ��� PUT ��A�h���X

		move.l	#$20000,d0		* d0.l = TEXT �v���[���̃X�g���C�h

		*-----[ T0 ]
		move.b	  (a0),(a1)		* 1 ���C����
		move.b	 2(a0),$80(a1)		* 2 ���C����
		move.b	 4(a0),$100(a1)		* 3 ���C����
		move.b	 6(a0),$180(a1)		* 4 ���C����
		move.b	 8(a0),$200(a1)		* 5 ���C����
		move.b	10(a0),$280(a1)		* 6 ���C����
		move.b	12(a0),$300(a1)		* 7 ���C����
		move.b	14(a0),$380(a1)		* 8 ���C����
		lea	$20(a0),a0		* ���̃v���[���� PCG �A�h���X��
		adda.l	d0,a1			* ���̃v���[���� TEXT �A�h���X��

		*-----[ T1 ]
		move.b	  (a0),(a1)		* 1 ���C����
		move.b	 2(a0),$80(a1)		* 2 ���C����
		move.b	 4(a0),$100(a1)		* 3 ���C����
		move.b	 6(a0),$180(a1)		* 4 ���C����
		move.b	 8(a0),$200(a1)		* 5 ���C����
		move.b	10(a0),$280(a1)		* 6 ���C����
		move.b	12(a0),$300(a1)		* 7 ���C����
		move.b	14(a0),$380(a1)		* 8 ���C����
		lea	$20(a0),a0		* ���̃v���[���� PCG �A�h���X��
		adda.l	d0,a1			* ���̃v���[���� TEXT �A�h���X��

		*-----[ T2 ]
		move.b	  (a0),(a1)		* 1 ���C����
		move.b	 2(a0),$80(a1)		* 2 ���C����
		move.b	 4(a0),$100(a1)		* 3 ���C����
		move.b	 6(a0),$180(a1)		* 4 ���C����
		move.b	 8(a0),$200(a1)		* 5 ���C����
		move.b	10(a0),$280(a1)		* 6 ���C����
		move.b	12(a0),$300(a1)		* 7 ���C����
		move.b	14(a0),$380(a1)		* 8 ���C����
		lea	$20(a0),a0		* ���̃v���[���� PCG �A�h���X��
		adda.l	d0,a1			* ���̃v���[���� TEXT �A�h���X��

		*-----[ T3 ]
		move.b	  (a0),(a1)		* 1 ���C����
		move.b	 2(a0),$80(a1)		* 2 ���C����
		move.b	 4(a0),$100(a1)		* 3 ���C����
		move.b	 6(a0),$180(a1)		* 4 ���C����
		move.b	 8(a0),$200(a1)		* 5 ���C����
		move.b	10(a0),$280(a1)		* 6 ���C����
		move.b	12(a0),$300(a1)		* 7 ���C����
		move.b	14(a0),$380(a1)		* 8 ���C����


	*=====[ ���[�U�[���[�h�� ]
		move.l	usp_bak(pc),d0
		bmi.b	@F			* ���[�U�[���[�h������s����Ă����̂Ŗ߂��K�v�Ȃ�
			movea.l	d0,a1
			iocs	_B_SUPER	* ���[�U�[���[�h��
		@@:


	*=====[ return ]
	rts



*==========================================================================
*
* �����F
*	void ftx_fnt16_put(short x, short y, short cd);
*
* �����F
*	x :
*		�\���� x ���W�i0�`63�j
*	y :
*		�\���� y ���W�i0�`63�j
*	cd :
*		�\������e�L�X�g PCG �i���o�[�i0�`65535�j
*
*==========================================================================

_ftx_fnt16_put

A7ID	=	4			*   �X�^�b�N�� return��A�h���X  [ 4 byte ]
					* + �ޔ����W�X�^�̑S�o�C�g��     [ 0 byte ]

	*=====[ �X�[�p�[�o�C�U���[�h�� ]
		suba.l	a1,a1
		iocs	_B_SUPER	* �X�[�p�[�o�C�U���[�h��
		move.l	d0,usp_bak	* ���X�X�[�p�[�o�C�U���[�h�̏ꍇ�� d0.l=-1


	*=====[ �����A�h���X�v�Z ]
		*-----[ GET �A�h���X ]
		move.l	A7ID+arg3_l(sp),d0	* d0.l = �p�^�[���R�[�h
		lsl.l	#7,d0			* d0.l = �p�^�[���R�[�h * 128
		movea.l	pcg_adr(pc),a0		* a0.l = PCG �f�[�^�̃A�h���X
		adda.l	d0,a0			* a0.l += d0.l
						* a0.l = PCG �ǂݏo���J�n�A�h���X

		*------[ PUT �A�h���X ]
		movea.l	#$E00000,a1		* a1.l = T0 �� �J�n�A�h���X
		move.w	A7ID+arg1_w(sp),d0	* d0.w = x
		andi.w	#63,d0			* d0.w = x & 63
		add.w	d0,d0			* d0.w = (x & 63) * 2
		adda.w	d0,a1			* a1.l += d0.w

		move.w	A7ID+arg2_w(sp),d0	* d0.w = y
		andi.l	#63,d0			* d0.l = y & 63
						*	PCG 1 �� Y ���� 16 �h�b�g
						*	TEXT ��� Y ���� 1 �h�b�g������ 128 �o�C�g
						*	16 * 128 = 1 << 11 �Ȃ̂ŁA11 �r�b�g�̍��V�t�g���K�v�B
						*	�����O�T�C�Y�� 11 �r�b�g�̍��V�t�g��
						*	8+2n = 30 �N���b�N������B
						*	������ swap �ƉE 5 �r�b�g�V�t�g���p�������������ŁA
						*	���v 4+18 = 22 �N���b�N�ōςށB
		swap	d0			* 4 �N���b�N
		lsr.l	#5,d0			* 8+2n (=18 �N���b�N)
		adda.l	d0,a1			* a1.l += d0.l
						* a1.l = TEXT ��� PUT ��A�h���X


	*=====[ FONT PUT ]
						* a0.l = PCG �ǂݏo���J�n�A�h���X
						* a1.l = TEXT ��� PUT ��A�h���X

		move.l	#$20000,d0		* d0.l = TEXT �v���[���̃X�g���C�h


		*-----[ T0 ]
		move.w	(a0)+,(a1)		*  1 ���C����
		move.w	(a0)+,$80(a1)		*  2 ���C����
		move.w	(a0)+,$100(a1)		*  3 ���C����
		move.w	(a0)+,$180(a1)		*  4 ���C����
		move.w	(a0)+,$200(a1)		*  5 ���C����
		move.w	(a0)+,$280(a1)		*  6 ���C����
		move.w	(a0)+,$300(a1)		*  7 ���C����
		move.w	(a0)+,$380(a1)		*  8 ���C����
		move.w	(a0)+,$400(a1)		*  9 ���C����
		move.w	(a0)+,$480(a1)		* 10 ���C����
		move.w	(a0)+,$500(a1)		* 11 ���C����
		move.w	(a0)+,$580(a1)		* 12 ���C����
		move.w	(a0)+,$600(a1)		* 13 ���C����
		move.w	(a0)+,$680(a1)		* 14 ���C����
		move.w	(a0)+,$700(a1)		* 15 ���C����
		move.w	(a0)+,$780(a1)		* 16 ���C����
		adda.l	d0,a1			* ���̃v���[���� TEXT �A�h���X��

		*-----[ T1 ]
		move.w	(a0)+,(a1)		*  1 ���C����
		move.w	(a0)+,$80(a1)		*  2 ���C����
		move.w	(a0)+,$100(a1)		*  3 ���C����
		move.w	(a0)+,$180(a1)		*  4 ���C����
		move.w	(a0)+,$200(a1)		*  5 ���C����
		move.w	(a0)+,$280(a1)		*  6 ���C����
		move.w	(a0)+,$300(a1)		*  7 ���C����
		move.w	(a0)+,$380(a1)		*  8 ���C����
		move.w	(a0)+,$400(a1)		*  9 ���C����
		move.w	(a0)+,$480(a1)		* 10 ���C����
		move.w	(a0)+,$500(a1)		* 11 ���C����
		move.w	(a0)+,$580(a1)		* 12 ���C����
		move.w	(a0)+,$600(a1)		* 13 ���C����
		move.w	(a0)+,$680(a1)		* 14 ���C����
		move.w	(a0)+,$700(a1)		* 15 ���C����
		move.w	(a0)+,$780(a1)		* 16 ���C����
		adda.l	d0,a1			* ���̃v���[���� TEXT �A�h���X��

		*-----[ T2 ]
		move.w	(a0)+,(a1)		*  1 ���C����
		move.w	(a0)+,$80(a1)		*  2 ���C����
		move.w	(a0)+,$100(a1)		*  3 ���C����
		move.w	(a0)+,$180(a1)		*  4 ���C����
		move.w	(a0)+,$200(a1)		*  5 ���C����
		move.w	(a0)+,$280(a1)		*  6 ���C����
		move.w	(a0)+,$300(a1)		*  7 ���C����
		move.w	(a0)+,$380(a1)		*  8 ���C����
		move.w	(a0)+,$400(a1)		*  9 ���C����
		move.w	(a0)+,$480(a1)		* 10 ���C����
		move.w	(a0)+,$500(a1)		* 11 ���C����
		move.w	(a0)+,$580(a1)		* 12 ���C����
		move.w	(a0)+,$600(a1)		* 13 ���C����
		move.w	(a0)+,$680(a1)		* 14 ���C����
		move.w	(a0)+,$700(a1)		* 15 ���C����
		move.w	(a0)+,$780(a1)		* 16 ���C����
		adda.l	d0,a1			* ���̃v���[���� TEXT �A�h���X��

		*-----[ T3 ]
		move.w	(a0)+,(a1)		*  1 ���C����
		move.w	(a0)+,$80(a1)		*  2 ���C����
		move.w	(a0)+,$100(a1)		*  3 ���C����
		move.w	(a0)+,$180(a1)		*  4 ���C����
		move.w	(a0)+,$200(a1)		*  5 ���C����
		move.w	(a0)+,$280(a1)		*  6 ���C����
		move.w	(a0)+,$300(a1)		*  7 ���C����
		move.w	(a0)+,$380(a1)		*  8 ���C����
		move.w	(a0)+,$400(a1)		*  9 ���C����
		move.w	(a0)+,$480(a1)		* 10 ���C����
		move.w	(a0)+,$500(a1)		* 11 ���C����
		move.w	(a0)+,$580(a1)		* 12 ���C����
		move.w	(a0)+,$600(a1)		* 13 ���C����
		move.w	(a0)+,$680(a1)		* 14 ���C����
		move.w	(a0)+,$700(a1)		* 15 ���C����
		move.w	(a0)+,$780(a1)		* 16 ���C����


	*=====[ ���[�U�[���[�h�� ]
		move.l	usp_bak(pc),d0
		bmi.b	@F			* ���[�U�[���[�h������s����Ă����̂Ŗ߂��K�v�Ȃ�
			movea.l	d0,a1
			iocs	_B_SUPER	* ���[�U�[���[�h��
		@@:

	*=====[ return ]
	rts



*==========================================================================
*
* �����Fvoid ftx_clr();
*
*==========================================================================

_ftx_clr

A7ID	=	4 + (5+4)*4		*   �X�^�b�N�� return��A�h���X  [ 4 byte ]
					* + �ޔ����W�X�^�̑S�o�C�g��     [ 0 byte ]

	movem.l	d3-d7/a3-a6,-(a7)	* ���W�X�^�ޔ�

	*=====[ �X�[�p�[�o�C�U���[�h�� ]
		suba.l	a1,a1
		iocs	_B_SUPER	* �X�[�p�[�o�C�U���[�h��
		move.l	d0,usp_bak	* ���X�X�[�p�[�o�C�U���[�h�̏ꍇ�� d0.l=-1

	*=====[ �e�L�X�g�N���A���s ]
		move.w	$E8002A,CRTC_R21_bak		* CRTC_R21 ���ݒl�̑ޔ�
		move.w	#%00000001_1111_0000,$E8002A	* T0�`T3 �����A�N�Z�X

		movea.l	#$E20000,a6			* a6.l = T0 �̊J�n�A�h���X
		moveq	#0,d1
		moveq	#0,d2
		moveq	#0,d3
		moveq	#0,d4
		moveq	#0,d5
		moveq	#0,d6
		moveq	#0,d7
		suba.l	a0,a0
		suba.l	a1,a1
		suba.l	a2,a2
		suba.l	a3,a3
		suba.l	a4,a4
		suba.l	a5,a5
							* a0-d0/a0-a5 �� 0 ���i�[����

		*-----[ 32768 �����O���[�h�N���A ]
		move.w	#511,d0				* dbra �J�E���^
	TCLR_LOOP:
		movem.l	d1-d7/a0-a5,-(a6)		* 13.l
		movem.l	d1-d7/a0-a5,-(a6)		* 13.l ���v 26.l
		movem.l	d1-d7/a0-a5,-(a6)		* 13.l ���v 39.l
		movem.l	d1-d7/a0-a5,-(a6)		* 13.l ���v 52.l
		movem.l	d1-d7/a0-a4,-(a6)		* 12.l ���v 64.l
		dbra	d0,TCLR_LOOP

		move.w	CRTC_R21_bak(pc),$E8002A	* CRTC_R21 ���ݒl�̕���

	*=====[ ���[�U�[���[�h�� ]
		move.l	usp_bak(pc),d0
		bmi.b	@F			* ���[�U�[���[�h������s����Ă����̂Ŗ߂��K�v�Ȃ�
			movea.l	d0,a1
			iocs	_B_SUPER	* ���[�U�[���[�h��
		@@:

	*=====[ return ]
	movem.l	(a7)+,d3-d7/a3-a6	* ���W�X�^����

	rts



*==========================================================================
*
* �����F
*	void ftx_scroll_set(short x, short y);
*
* �����F
*	x :
*		X ���W�i0�`1023�j
*	y :
*		Y ���W�i0�`1023�j
*
*==========================================================================

_ftx_scroll_set

A7ID	=	4			*   �X�^�b�N�� return��A�h���X  [ 4 byte ]
					* + �ޔ����W�X�^�̑S�o�C�g��     [ 0 byte ]

	*=====[ �X�[�p�[�o�C�U���[�h�� ]
		suba.l	a1,a1
		iocs	_B_SUPER	* �X�[�p�[�o�C�U���[�h��
		move.l	d0,usp_bak	* ���X�X�[�p�[�o�C�U���[�h�̏ꍇ�� d0.l=-1

	*=====[ �e�N�X�g�X�N���[�����W�X�^�������� ]
		move.w	A7ID+arg1_w(sp),$E80014
		move.w	A7ID+arg2_w(sp),$E80016

	*=====[ ���[�U�[���[�h�� ]
		move.l	usp_bak(pc),d0
		bmi.b	@F			* ���[�U�[���[�h������s����Ă����̂Ŗ߂��K�v�Ȃ�
			movea.l	d0,a1
			iocs	_B_SUPER	* ���[�U�[���[�h��
		@@:

	*=====[ return ]
	rts



*==========================================================================
*
* �����F
*	void ftx_palette_set(short idx, short color);
*
* �����F
*	idx :
*		�p���b�g�C���f�N�X�i0�`15�j
*	color :
*		�J���[�R�[�h�i0�`65536�j
*
*==========================================================================

_ftx_palette_set

A7ID	=	4			*   �X�^�b�N�� return��A�h���X  [ 4 byte ]
					* + �ޔ����W�X�^�̑S�o�C�g��     [ 0 byte ]

	*=====[ IOCS �R�[���Ɋۓ��� ]
		move.w	A7ID+arg1_w(sp),d1
		move.l	A7ID+arg2_l(sp),d2
		iocs	_TPALET2

	*=====[ return ]
	rts



*==========================================================================
*
* �����F
*	void ftx_fnt16_cnv(const void *sp_pcg, void *fnt_pcg);
*
* �����F
*	sp_pcg :
*		�ϊ����̃X�v���C�g PCG �̃|�C���^
*	fnt_pcg :
*		�t�H���g PCG �ϊ����ʏo�͐�̃|�C���^
*
*==========================================================================

_ftx_fnt16_cnv

A7ID	=	4+4*2			*   �X�^�b�N�� return��A�h���X  [ 4 byte ]
					* + �ޔ����W�X�^�̑S�o�C�g��     [ 4*2 byte ]

	movem.l	d6-d7,-(a7)		* ���W�X�^�ޔ�

	movea.l	A7ID+arg1_l(sp),a1	* a1.l = pU16DstPcg
	movea.l	A7ID+arg2_l(sp),a0	* a0.l = pU8SrcPcg


	moveq.l	#0,d7			* d7 = 0

	*=====[ Y ���W�̃��[�v ]
loop:
		moveq.l	#0,d0			* d0.l = 0
		move.w	d0,    (a0,d7.w)	* pU16DstPcg[y     ] = 0
		move.w	d0,16*2(a0,d7.w)	* pU16DstPcg[y + 16] = 0
		move.w	d0,32*2(a0,d7.w)	* pU16DstPcg[y + 32] = 0
		move.w	d0,48*2(a0,d7.w)	* pU16DstPcg[y + 48] = 0

		moveq.l	#6,d6			* d6 = 6

		*=====[ X ���W�̃��[�v ]
		@@:
			moveq.l	#0,d0			* d0 = 0
			moveq.l	#0,d1			* d1 = 0

			move.b	(a1,64),d1		* d1.l = tmp1
			move.b	(a1)+,d0		* d0.l = tmp0

			lsl.w	#8,d0			* d0.w = tmp0 << 8
			or.b	d1,d0			* d0.w = (tmp0 << 8) | tmp1
							*      = tmp01

			move.w	d0,d1			* d1.w = tmp01
			rol.w	d6,d1			* d1.w = tmp01 << (6 - x)
							*      = tmp
			move.w	#$0101,d2		* d2.w = 0x0101
			lsl.w	d6,d2			* d2.w = 0x0101 << (6 - x)
							*      = mask

							*---------------------------------------
			move.w	d1,d0			* d0.w = tmp
			and.w	d2,d0			* d0.w = tmp & mask
			or.w	d0,(a0,d7.w)		* pS16DstPcg[y     ] |= tmp & mask;

			ror.w	#1,d1			* tmp >>= 1

			move.w	d1,d0			* d0.w = tmp
			and.w	d2,d0			* d0.w = tmp & mask
			or.w	d0,16*2(a0,d7.w)	* pS16DstPcg[y + 16] |= tmp & mask;

			ror.w	#1,d1			* tmp >>= 1

			move.w	d1,d0			* d0.w = tmp
			and.w	d2,d0			* d0.w = tmp & mask
			or.w	d0,32*2(a0,d7.w)	* pS16DstPcg[y + 32] |= tmp & mask;

			ror.w	#1,d1			* tmp >>= 1

			move.w	d1,d0			* d0.w = tmp
			and.w	d2,d0			* d0.w = tmp & mask
			or.w	d0,48*2(a0,d7.w)	* pS16DstPcg[y + 48] |= tmp & mask;
							*---------------------------------------

			add.w	d2,d2			* mask <<= 1

							*---------------------------------------
			move.w	d1,d0			* d0.w = tmp
			and.w	d2,d0			* d0.w = tmp & mask
			or.w	d0,(a0,d7.w)		* pS16DstPcg[y     ] |= tmp & mask;

			ror.w	#1,d1			* tmp >>= 1

			move.w	d1,d0			* d0.w = tmp
			and.w	d2,d0			* d0.w = tmp & mask
			or.w	d0,16*2(a0,d7.w)	* pS16DstPcg[y + 16] |= tmp & mask;

			ror.w	#1,d1			* tmp >>= 1

			move.w	d1,d0			* d0.w = tmp
			and.w	d2,d0			* d0.w = tmp & mask
			or.w	d0,32*2(a0,d7.w)	* pS16DstPcg[y + 32] |= tmp & mask;

			ror.w	#1,d1			* tmp >>= 1

			move.w	d1,d0			* d0.w = tmp
			and.w	d2,d0			* d0.w = tmp & mask
			or.w	d0,48*2(a0,d7.w)	* pS16DstPcg[y + 48] |= tmp & mask;
							*---------------------------------------

			*------[ ���̗v�f�� ]
			subq.w	#2,d6
			bpl.b	@b

		*------[ ���̗v�f�� ]
		addq.w	#2,d7
		cmp.w	#16*2,d7
		blt	loop

	*=====[ return ]
	movem.l	(a7)+,d6-d7		* ���W�X�^����
	rts



*==========================================================================
*
* �������m�ۂȂ�
*
*==========================================================================

	.even

usp_bak		dc.l	0
pcg_adr		dc.l	0
CRTC_R21_bak	dc.w	0


