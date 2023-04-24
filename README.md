# CSCM28 Penetration Testing Demo - Meltdown Exploit

### Alfie Richardson - 851009 
### Neil Woodhouse - 851182


## Important Note: Hardware-Specific Nature
The exploit we have chosen is reliant on specific vulnerabilities in the hardware implementation of [speculative branch execution](https://en.wikipedia.org/wiki/Speculative_execution) on some CPUs. 

Because of this, the vulnerability requires specific hardware to run, so may not run on any given system. Additionally, updates to operating systems have introduced some patches to it, so a vulnerable OS instance must be used. 

For the demo, we used an old workstation (CPU = Intel i5-4460s) running Arch Linux. Instructions on setting up a correctly-configured Arch installation on vulnerable hardware are included below. 

A vulnerability checker tool is included in this zip to check whether a given system may be vulnerable to the exploit. 

# Installation and Setup

Our demo system is running the Arch distribution of Linux. There's a few key reasons we chose to use Arch:

- We have prior experience in using Arch, and the resources for modifying it.
- A basic Arch install will boot to a terminal by default, which is all we need to set up the vulnerabilities on the system.
- Arch does not ship with microcode updates by default, and the microcode updates patch Meltdown.

## Section on OS Setup

After you have found a system you believe is vulnerable to Meltdown, the easiest way to install Arch on it is to follow the wiki or a tutorial.

- **Choose GRUB as your bootloader**

- **DO NOT INSTALL THE MICROCODE**

> Installation Wiki: https://wiki.archlinux.org/title/Installation_guide

> GRUB Installation Wiki: https://wiki.archlinux.org/title/GRUB

> Video Demonstration of Arch Install and GRUB Configuration: https://youtu.be/PQgyW10xD8s


## Run the setup.sh script and restart
This script disables operating-system level mitigations for the Meltdown and Spectre exploits.
In the real-world this mainly reflects older machines, which may still be running operating-systems from before these mitigations were introduced. However, some users may also run systems with the mitigations intentionally disabled, to avoid their negative performance impact. 

## Compile and Run vulnerability checker
To do this run:
```bash
cd ./vuln-checker
chmod +x spectre-meltdown-checker.sh
sudo ./spectre-meltdown-checker.sh
```
This program runs some basic checks to see which speculative execution exploits, such as Spectre and Meltdown, your system is vulnerable to. If the system is correctly set-up, you should see that it is vulnerable to several variants of these exploits. 

## Compile and run our copy of the meltdown PoC

First, run secret. This creates a process which contains a secret string inside its isolated system memory. It provides a memory address that the secret is stored at. 
```bash
cd ./exploits
make
sudo ./secret
```

Then run physical_reader, providing it with the standard system memory offset (0xffff888000000000), and the memory address from running secret. 
This program attempts to read the data contained at the given memory location. Since it is isolated to a seperate process, this should not be possible, however it uses Meltdown to extract it through the CPU cache, bypassing normal protections. 
```bash
./physical_reader 0xffff888000000000 [MEMORY_ADDRESS_FROM_SECRET]
```

Note: Since physical_reader is reliant on CPU side-channels to extract data, it is highly sensitive to other processes on the system. This can cause it to read corrupted data. This is an inherent limitation to the exploit, which is normally avoided by simply running the exploit multiple times until it successfully extracts the target data. 

## Run the patch.sh script and restart
This script re-enables operating-system level mitigations for the vulnerability. 

After these are enabled, this Meltdown exploit should no longer be possible. 
This is because these mitigations introduce a feature called Page Table Isolation. This seperates the system memory into multiple page tables which must be completely switched to access memory from a seperate one. 

To verify that the system is patched, you can run the vulnerability checker again with: 
```bash
cd ./vuln-checker
sudo ./spectre-meltdown-checker.sh
```
It should show significantly fewer active vulnerabilities. It may still show some, because there are other Speculative Execution exploits that require additional patching, or for which patches do not currently exist. 

## Acknowledgements:

Exploit Folder Contents from Meltdown PoC: https://github.com/IAIK/meltdown

Vuln-Checker Contents from Vulnerability Checker: https://github.com/speed47/spectre-meltdown-checker