## Background
Broadlink produces a nifty wifi-enabled IR blaster, but doesn't provide an API for it. The only known interface is an
Android SDK. An Android 'RM Bridge' application exists to provide an http interface, but it requires an always-on
Android device to be placed inside your home network.

This project aims to provide a portable, web-deployable HTTP interface to these Wifi IR Blasters.

The Broadlink e-control Android application uses UDP packets to send commands to the IR blaster. Since no API documentation
is provided by the OEM, acket analysis is employed to determine the format of valid UDP packets.

#### Example UDP packet to toggle power on Onkyo Reciever
```
5a a5 aa 55 5a a5 aa 55    <= Control Sequence - All packets start with this
00 00 00 00 00 00 00 00    <= 0-byte separator
00 00 00 00 00 00 00 00    <= 0-byte separator
00 00 00 00 00 00 00 00    <= 0-byte separator
fa fc 00 00 37 27 6a 00    <= ??
cc 82 54 2b e4 0d 43 b4    <= First and second bytes are a debounce counter. Successive commands with the same value here are ignored by the device.
02 00 00 00 78 c8 00 00    
b4 29 cf 34 4a 64 78 26
74 0a 82 df 9e ed e4 b1
3c 85 1e 6c 8d 7b ce f6
86 96 aa f2 66 65 65 b7
cf 9e 81 6f ec 83 b1 b0
fa c9 03 19 b8 af 15 ed
a3 2b 26 04 7b 1d 0c 73
fa cc f7 2b df 55 41 39
b5 34 a2 3e 8c b6 db d2
bf 69 99 d1 6a 79 db ee
6e 99 ee cb e2 d4 c3 7d
52 7f e5 d0 32 17 1f fb
```

## Usage
