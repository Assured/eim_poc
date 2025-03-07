# eim_poc
PoC of EIM interface between iMX and FPGA for the CrypTkey board.

## Introduction
This repository is used to develop a Proof of Concept (PoC) for an EIM interface betwwen a iMX MCU and a FPGA, more specifically the Lattice ECP5 on the OrangeCrab board. On future boards we can expand the width of buses, but the interface behaviour should not fundamentally change. The interface is built on the the EIM used in the Cryptech project in the Novena based prototype. Later versions used a STM32 as MCU and instead used the STM32 external bus.
