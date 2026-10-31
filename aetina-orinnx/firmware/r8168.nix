{ runCommand, linux-firmware }:

# The Realtek NIC files the Orin NX carrier wants, as JetPack picks them from linux-firmware.
runCommand "r8168-firmware" { } ''
  install -Dm0444 -t "$out/lib/firmware/rtl_nic" ${linux-firmware}/lib/firmware/rtl_nic/rtl8168d-1.fw
  install -Dm0444 -t "$out/lib/firmware/rtl_nic" ${linux-firmware}/lib/firmware/rtl_nic/rtl8168d-2.fw
  install -Dm0444 -t "$out/lib/firmware/rtl_nic" ${linux-firmware}/lib/firmware/rtl_nic/rtl8168e-1.fw
  install -Dm0444 -t "$out/lib/firmware/rtl_nic" ${linux-firmware}/lib/firmware/rtl_nic/rtl8168e-2.fw
  install -Dm0444 -t "$out/lib/firmware/rtl_nic" ${linux-firmware}/lib/firmware/rtl_nic/rtl8168e-3.fw
  install -Dm0444 -t "$out/lib/firmware/rtl_nic" ${linux-firmware}/lib/firmware/rtl_nic/rtl8168f-1.fw
  install -Dm0444 -t "$out/lib/firmware/rtl_nic" ${linux-firmware}/lib/firmware/rtl_nic/rtl8168f-2.fw
  install -Dm0444 -t "$out/lib/firmware/rtl_nic" ${linux-firmware}/lib/firmware/rtl_nic/rtl8105e-1.fw
  install -Dm0444 -t "$out/lib/firmware/rtl_nic" ${linux-firmware}/lib/firmware/rtl_nic/rtl8402-1.fw
  install -Dm0444 -t "$out/lib/firmware/rtl_nic" ${linux-firmware}/lib/firmware/rtl_nic/rtl8411-1.fw
  install -Dm0444 -t "$out/lib/firmware/rtl_nic" ${linux-firmware}/lib/firmware/rtl_nic/rtl8411-2.fw
  install -Dm0444 -t "$out/lib/firmware/rtl_nic" ${linux-firmware}/lib/firmware/rtl_nic/rtl8106e-1.fw
  install -Dm0444 -t "$out/lib/firmware/rtl_nic" ${linux-firmware}/lib/firmware/rtl_nic/rtl8106e-2.fw
  install -Dm0444 -t "$out/lib/firmware/rtl_nic" ${linux-firmware}/lib/firmware/rtl_nic/rtl8168g-2.fw
  install -Dm0444 -t "$out/lib/firmware/rtl_nic" ${linux-firmware}/lib/firmware/rtl_nic/rtl8168g-3.fw
  install -Dm0444 -t "$out/lib/firmware/rtl_nic" ${linux-firmware}/lib/firmware/rtl_nic/rtl8168h-2.fw
  install -Dm0444 -t "$out/lib/firmware/rtl_nic" ${linux-firmware}/lib/firmware/rtl_nic/rtl8168fp-3.fw
  install -Dm0444 -t "$out/lib/firmware/rtl_nic" ${linux-firmware}/lib/firmware/rtl_nic/rtl8107e-2.fw
  install -Dm0444 -t "$out/lib/firmware/rtl_nic" ${linux-firmware}/lib/firmware/rtl_nic/rtl8125a-3.fw
  install -Dm0444 -t "$out/lib/firmware/rtl_nic" ${linux-firmware}/lib/firmware/rtl_nic/rtl8125b-2.fw
  install -Dm0444 -t "$out/lib/firmware/rtl_nic" ${linux-firmware}/lib/firmware/rtl_nic/rtl8126a-2.fw
''
