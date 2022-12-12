/*
	FTX �Ή� �X�v���C�g PCG �� �t�H���g�f�[�^�ϊ��c�[��
*/

#include <stdint.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "../FTX/FTX2lib.H"


static void
SpritePcgToFontPcg(
	const	void	*pSrcPcg,
			void	*pDstPcg
){
	int x, y;
	const uint8_t *pU8SrcPcg = (const uint8_t *)pSrcPcg;
	uint16_t *pS16DstPcg = (uint16_t *)pDstPcg;

#if 0
/* �i�C�[�u���� */
	for (y = 0; y < 16; y++) {
		pS16DstPcg[y     ] = 0;
		pS16DstPcg[y + 16] = 0;
		pS16DstPcg[y + 32] = 0;
		pS16DstPcg[y + 48] = 0;

		for (x = 0; x < 8; x += 2) {
			int tmp0 = * pU8SrcPcg;
			int tmp1 = *(pU8SrcPcg + 64);
			pU8SrcPcg++;

			pS16DstPcg[y     ] |= ((tmp0      & 1) / 1) << (15 - (x + 1));
			pS16DstPcg[y + 16] |= ((tmp0      & 2) / 2) << (15 - (x + 1));
			pS16DstPcg[y + 32] |= ((tmp0      & 4) / 4) << (15 - (x + 1));
			pS16DstPcg[y + 48] |= ((tmp0      & 8) / 8) << (15 - (x + 1));

			pS16DstPcg[y     ] |= ((tmp0 / 16 & 1) / 1) << (15 - (x + 0));
			pS16DstPcg[y + 16] |= ((tmp0 / 16 & 2) / 2) << (15 - (x + 0));
			pS16DstPcg[y + 32] |= ((tmp0 / 16 & 4) / 4) << (15 - (x + 0));
			pS16DstPcg[y + 48] |= ((tmp0 / 16 & 8) / 8) << (15 - (x + 0));

			pS16DstPcg[y     ] |= ((tmp1      & 1) / 1) << (15 - (x + 9));
			pS16DstPcg[y + 16] |= ((tmp1      & 2) / 2) << (15 - (x + 9));
			pS16DstPcg[y + 32] |= ((tmp1      & 4) / 4) << (15 - (x + 9));
			pS16DstPcg[y + 48] |= ((tmp1      & 8) / 8) << (15 - (x + 9));

			pS16DstPcg[y     ] |= ((tmp1 / 16 & 1) / 1) << (15 - (x + 8));
			pS16DstPcg[y + 16] |= ((tmp1 / 16 & 2) / 2) << (15 - (x + 8));
			pS16DstPcg[y + 32] |= ((tmp1 / 16 & 4) / 4) << (15 - (x + 8));
			pS16DstPcg[y + 48] |= ((tmp1 / 16 & 8) / 8) << (15 - (x + 8));
		}
	}
#else
/* �œK������ */
	#if 0
	/* C ���� */
	for (y = 0; y < 16; y++) {
		pS16DstPcg[y     ] = 0;
		pS16DstPcg[y + 16] = 0;
		pS16DstPcg[y + 32] = 0;
		pS16DstPcg[y + 48] = 0;

		for (x = 0; x < 8; x += 2) {
			int tmp0 = * pU8SrcPcg;
			int tmp1 = *(pU8SrcPcg + 64);
			pU8SrcPcg++;

			{
				unsigned int tmp01 = (tmp0 << 8) | tmp1;

				unsigned int tmp = tmp01 << (6 - x);
				unsigned short mask = 0x0101 << (6 - x);
				pS16DstPcg[y     ] |= (tmp       & mask);
				tmp >>= 1;
				pS16DstPcg[y + 16] |= (tmp       & mask);
				tmp >>= 1;
				pS16DstPcg[y + 32] |= (tmp       & mask);
				tmp >>= 1;
				pS16DstPcg[y + 48] |= (tmp       & mask);

				mask <<= 1;
				pS16DstPcg[y     ] |= (tmp       & mask);
				tmp >>= 1;
				pS16DstPcg[y + 16] |= (tmp       & mask);
				tmp >>= 1;
				pS16DstPcg[y + 32] |= (tmp       & mask);
				tmp >>= 1;
				pS16DstPcg[y + 48] |= (tmp       & mask);
			}
		}
	}
	#else
	/* asm ���� */
	ftx_fnt16_cnv(pU8SrcPcg, pS16DstPcg);
	#endif
#endif
}

static bool
FtxConverter(
	const char *pszInputFileName,
	const char *pszOutputFileName
){
	size_t srcFileSize;
	size_t dstFileSize;
	int nPcg;
	FILE *pSrcFile;
	FILE *pDstFile;

	/* �\�[�X�t�@�C�����J�� */
	pSrcFile = fopen(pszInputFileName, "rb");
	if (pSrcFile == NULL) {
		printf("%s ���J���܂���B\n", pszInputFileName);
		return false;
	}

	/* �f�X�e�B�l�[�V�����t�@�C�����J�� */
	pDstFile = fopen(pszOutputFileName, "wb");
	if (pDstFile == NULL) {
		printf("%s ���J���܂���B\n", pszOutputFileName);
		return false;
	}

	/* �\�[�X�t�@�C���̃T�C�Y�𒲂ׂ� */
	fseek(pSrcFile, 0, SEEK_END);
	srcFileSize = ftell(pSrcFile);
	fseek(pSrcFile, 0, SEEK_SET);

	/* �\�[�X�t�@�C���̃T�C�Y���� PCG �����ƁA�f�X�e�B�l�[�V�����t�@�C���T�C�Y������ */
	nPcg = srcFileSize / 128;
	dstFileSize = nPcg * 128;

	/* �R���o�[�g */
	{
		int i = 0;
		for (i = 0; i < nPcg; i++) {
			static int8_t srcBuffer[128];
			static int8_t dstBuffer[128];
			int ret;

			/* �\�[�X�t�@�C���̓ǂݍ��� */
			ret = fread(srcBuffer, 1, 128, pSrcFile);
			if (ret != 128) {
				printf("�t�@�C�����[�h�G���[�B\n");
				return false;
			}

			/* PCG �̕ϊ� */
			SpritePcgToFontPcg(srcBuffer, dstBuffer);

			/* �f�X�e�B�l�[�V�����t�@�C���̏������� */
			ret = fwrite(dstBuffer, 1, 128, pDstFile);
			if (ret != 128) {
				printf("�t�@�C�����C�g�G���[�B\n");
				return false;
			}
		}
	}

	/* �o�ߕ� */
	printf("%d PCG �ϊ����܂����B\n", nPcg);

	/* �t�@�C������� */
	fclose(pDstFile);
	fclose(pSrcFile);

	/* ����I�� */
	return true;
}


int
main(
	int		argc,
	char	**argv
){
	const	char	*pszInputFileName = NULL;
	const	char	*pszOutputFileName = NULL;

	/* �����Ȃ��ŋN�������ꍇ�̓w���v��\�����ďI�� */
	if (argc == 1) {
		printf(
			"\n"
			"[remarks]\n"
			"	X680x0 �̃X�v���C�g�f�[�^�i*.sp�j�����ɁA\n"
			"	FTX �p�t�H���g PCG �t�@�C���𐶐����܂��B\n"
			"\n"
			"[parameters]\n"
			"	-i ���̓t�@�C���� \n"
			"		���̓t�@�C�������w�肷��B\n"
			"	-o �o�̓t�@�C���� \n"
			"		�o�̓t�@�C�������w�肷��B\n"
			"\n"
		);

		/* ����I�� */
		return 0;
	}

	/* ������� */
	{
		int iArg = 1;
		while (iArg < argc) {
			if (strcmp(argv[iArg], "-i") == 0) {
				if (iArg + 1 >= argc) {
					printf("�����w�肪�s�����Ă��܂��B\n");

					/* �ُ�I�� */
					return 1;
				}
				pszInputFileName = argv[iArg + 1];
				iArg++;		/* �������X�L�b�v */
			} else
			if (strcmp(argv[iArg], "-o") == 0) {
				if (iArg + 1 >= argc) {
					printf("�����w�肪�s�����Ă��܂��B\n");

					/* �ُ�I�� */
					return 1;
				}
				pszOutputFileName = argv[iArg + 1];
				iArg++;		/* �������X�L�b�v */
			} else {
				printf("�����w�肪�s���ł��B\n");

				/* �ُ�I�� */
				return 1;
			}

			/* ���̗v�f�� */
			iArg++;
		}
	}

	/* �X�C�b�`�w�肪�s�\�����s���Ȃ�G���[���b�Z�[�W���o�͂��ďI�� */
	if (pszInputFileName == NULL) {
		printf("	���̓t�@�C�������w�肳��Ă��܂���B\n");

		/* �ُ�I�� */
		return 1;
	}
	if (pszOutputFileName == NULL) {
		printf("	�o�̓t�@�C�������w�肳��Ă��܂���B\n");

		/* �ُ�I�� */
		return 1;
	}

	/* ��͌��ʂ�\�� */
	if (1) {
		printf(
			"������͌���\n"
			"	-i %s\n"
			"	-o %s\n",
			pszInputFileName,
			pszOutputFileName
		);
	}

	/* �R���o�[�g�����{�̂ɔ�� */
	if (
		FtxConverter(
			pszInputFileName,
			pszOutputFileName
		) == false
	) {
		/* �ُ�I�� */
		printf("�ُ�I��\n");
		return 1;
	}

	/* ����I�� */
	printf("����I��\n");
	return 0;
}

