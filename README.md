# eim_poc
PoC of EIM interface between iMX and FPGA for the CrypTkey board.

## Introduction
This repository is used to develop a Proof of Concept (PoC) for an EIM interface betwwen a iMX MCU and a FPGA, more specifically the Lattice ECP5 on the OrangeCrab board. On future boards we can expand the width of buses, but the interface behaviour should not fundamentally change. The interface is built on the the EIM used in the Cryptech project in the Novena based prototype. Later versions used a STM32 as MCU and instead used the STM32 external bus.

## Goal
Being able to connect the MCU and the FPGA in a way that lets the MCU  use resources in the FPGA by reading and writing to addresses in memory. In the simplest form having the resources memory mapped and accessed through 32-bit words, 16-bit words or bytes. But it could also be through mailboxes, accessed through a set of addresses. This is actually closer to the idea behind the PoC.

## Idea
The available number of pins on the FPGA means that we can't create real addresses or data wordss for reading or writing. But we could use part of a 32-bit address (that the MCU sees) as a way to send commands and data in a simple protocol. Basically the MCU reads and writes a sequence of addresses and ends up being able to actually send and receive data. In a 


## Protocol
The MCU perform read or write information to a set of 32-bit addresses. However only the LSB is connected to the FPGA. And critically the LSB is not directly an address. Instead the LSB is interpreted as commands and data. An example:

The MCU perform:

1. Read 0x0000_0001 from adress 0x0000_0000
2. Write 0xffff_ffff to address 0x0000_0001
3. Write 0xffff_ffff to address 0x0000_00de
4. Write 0xffff_ffff to address 0x0000_00ad
5. Write 0xffff_ffff to address 0x0000_00be
6. Write 0xffff_ffff to address 0x0000_00ef

7. Read 0x01 from adress 0x0000_0000
8. Read 0xde from adress 0x0000_0002
9. Read 0xad from adress 0x0000_0002
10. Read 0be from adress 0x0000_0002
11. Read 0ef from adress 0x0000_0002


For the FPGA this would mean:

1. Return status. 0x01 means that the FPGA is ready to receive command
2. Command to store a 32-bit word into to the internal 32-bit register
3. Byte 0 of the word
4. Byte 1 of the word
5. Byte 2 of the word
6. Byte 3 of the word

1. Return status
2. Command to return a 32-bit word from the internal register
2. Return byte 0 of the word
2. Return byte 1 of the word
2. Return byte 2 of the word
2. Return byte 3 of the word

The values written are not important, the addresses are.

The FPGA will have:

1. A finite state machine that interpret the commands
2. A writable register 'LED' connected to the LEDs. Allows the MCU to perform blinkenlights
3. A writable register 'inv' that when read returns the inverse of the values written

This allow us to visually inspect that write accesses works. And then also verify that read operations works.

