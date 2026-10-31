# Copyright, Linaro Ltd, 2026
# SPDX-License-Identifier: BSD-3-Clause
#
# Fairphone (Gen. 6) — SM7635 "Milos"
# Speaker path: 2x Awinic AW88261 on Senary MI2S (LPASS LPI I2S2).
# The DSP addresses this interface as the WSA LPAIF block's primary I2S
# (downstream PAL backend "MI2S-LPAIF_WSA-RX-PRIMARY"), hence
# LPAIF_INTF_TYPE_WSA + I2S_INTF_TYPE_PRIMARY below.
#
include(`audioreach/audioreach.m4')
include(`audioreach/stream-subgraph.m4')
include(`audioreach/device-subgraph.m4')
include(`util/route.m4')
include(`util/mixer.m4')
include(`audioreach/tokens.m4')
dnl
dnl Senary MI2S BE DAI id (dt-bindings qcom,q6dsp-lpass-ports.h, v7.2+);
dnl not yet in audioreach.m4
define(`SENARY_MI2S_RX', `147') dnl
dnl
#
# Stream SubGraph for MultiMedia1 Playback
#
#  ______________________________________________
# |               Sub Graph 1                    |
# | [WR_SH] -> [PCM DEC] -> [PCM CONV] -> [LOG]  |- Kcontrol
# |______________________________________________|
#
dnl Playback MultiMedia1
STREAM_SG_PCM_ADD(audioreach/subgraph-stream-vol-playback.m4, FRONTEND_DAI_MULTIMEDIA1,
	`S16_LE', 48000, 48000, 2, 2,
	0x00004001, 0x00004001, 0x00006001, `110000')
dnl
dnl Capture MultiMedia2 (WCD9378 mics)
STREAM_SG_PCM_ADD(audioreach/subgraph-stream-capture.m4, FRONTEND_DAI_MULTIMEDIA2,
	`S16_LE', 48000, 48000, 1, 2,
	0x00004002, 0x00004002, 0x00006020, `110000')
dnl
#
# Device SubGraph for Senary MI2S RX Backend (stereo AW88261)
#
#         ___________________
#        |   Sub Graph 2     |
# Mixer -| [LOG] -> [I2S EP] |
#        |___________________|
#
dnl Senary MI2S Playback (32-bit slots: AW88261 boost needs 3.072 MHz BCLK)
DEVICE_SG_ADD(audioreach/subgraph-device-i2s-playback-mfc.m4, `Senary', SENARY_MI2S_RX,
	`S32_LE', 48000, 48000, 2, 2,
	LPAIF_INTF_TYPE_WSA, I2S_INTF_TYPE_PRIMARY, SD_LINE_IDX_I2S_SD0, DATA_FORMAT_FIXED_POINT,
	0x00004006, 0x00004006, 0x00006060, `SEN_MI2S_RX')

#
# Device SubGraph for the WCD9378 TX (mic capture) Backend
#
#          _____________________
#         |    Sub Graph 3      |
#  Mixer -| [CDC-DMA EP] -> [LOG] |
#         |_____________________|
#
dnl WCDTX Capture (TX macro decimators via RXTX LPAIF TX3 CDC-DMA)
DEVICE_SG_ADD(audioreach/subgraph-device-codec-dma-capture.m4, `TX_CODEC_DMA_TX_3', TX_CODEC_DMA_TX_3,
	`S16_LE', 48000, 48000, 1, 2,
	LPAIF_INTF_TYPE_RXTX, CODEC_INTF_IDX_TX3, 0, DATA_FORMAT_FIXED_POINT,
	0x00004008, 0x00004008, 0x00006130)

STREAM_DEVICE_PLAYBACK_MIXER(SENARY_MI2S_RX, ``SEN_MI2S_RX'', ``MultiMedia1'')
STREAM_DEVICE_PLAYBACK_ROUTE(SENARY_MI2S_RX, ``SEN_MI2S_RX Audio Mixer'', ``MultiMedia1, stream0.logger1'')

STREAM_DEVICE_CAPTURE_MIXER(FRONTEND_DAI_MULTIMEDIA2, ``TX_CODEC_DMA_TX_3'')
STREAM_DEVICE_CAPTURE_ROUTE(FRONTEND_DAI_MULTIMEDIA2, ``MultiMedia2 Mixer'', ``TX_CODEC_DMA_TX_3, device120.logger1'')
