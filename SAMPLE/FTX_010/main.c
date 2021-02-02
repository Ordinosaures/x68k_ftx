/*
	FTX ���p�T���v���v���O����

	�t�H���g PCG �f�[�^��ǂݍ��݁A�t�H���g�\�����s���܂��B
*/

#include <stdio.h>
#include <stdlib.h>
#include <doslib.h>
#include <iocslib.h>
#include "../../FTX/FTX2lib.H"

/* �t�H���g PCG �p�^�[���ő�g�p�� */
#define	FNT_MAX		256

/* �t�H���g PCG �f�[�^�t�@�C���ǂݍ��݃o�b�t�@ */
char fnt_pcg_dat[FNT_MAX * 128];

/* �p���b�g�f�[�^�t�@�C���ǂݍ��݃o�b�t�@ */
unsigned short pal_dat[256];


void main()
{
	int		i;
	FILE	*fp;

	/* 256x256dot 16�F �O���t�B�b�N�v���[��4�� 31KHz */
	CRTMOD(6);

	/* �J�[�\���\�� OFF */
	B_CUROFF();

	/* �t�H���g PCG �f�[�^�ǂݍ��� */
	fp = fopen("FONT.FNT", "rb");
	if (fp == NULL) return;
	fread(
		fnt_pcg_dat,
		128,		/* 1PCG = 128byte */
		256,		/* 256PCG */
		fp
	);
	fclose(fp);

	/* �X�v���C�g�p���b�g�f�[�^�ǂݍ��� */
	fp = fopen("FONT.PAL", "rb");
	if (fp == NULL) return;
	fread(
		pal_dat,
		2,			/* 1color = 2byte */
		256,		/* 16color * 16block */
		fp
	);
	fclose(fp);

	/* �X�v���C�g�p���b�g #1 ���e�L�X�g�p���b�g�ɓ]�� */
	for (i = 0; i < 16; i++) {
		ftx_palette_set(i, pal_dat[i + 16]);
	}

	/* �t�H���g PCG �f�[�^���w�� */
	ftx_pcgdat_set(fnt_pcg_dat);

	/* �t�H���g�`�� */
#if 1
	for (i = 0; i < 256; i++) {
		int x = i & 15;
		int y = i >> 4;
		ftx_fnt16_put(x, y, i);
	}
#else
	/*
		��L�Ɠ����`�挋�ʂ� 8x8 �h�b�g�t�H���g�ŕ`���ꍇ�A
		�ȉ��̂悤�ɂȂ�B
	*/
	for (i = 0; i < 256; i++) {
		int x = i & 15;
		int y = i >> 4;
		ftx_fnt8_put(x * 2    , y * 2    , i * 4    );
		ftx_fnt8_put(x * 2    , y * 2 + 1, i * 4 + 1);
		ftx_fnt8_put(x * 2 + 1, y * 2    , i * 4 + 2);
		ftx_fnt8_put(x * 2 + 1, y * 2 + 1, i * 4 + 3);
	}
#endif

	/* �����L�[�������܂Ń��[�v */
	while (INPOUT(0xFF) == 0) {}

	/*
		�e�L�X�g��ʃN���A�B
		��������Ȃ��ƁA�v���O�����I������e�L�X�g��ʏ��
		�`�挋�ʂ��c���Ă��܂��B
	*/
	ftx_clr();

	/* ��ʃ��[�h��߂� */
	CRTMOD(0x10);
}

