#!/bin/bash

OUTFILE="system_info.txt"

# Start report
{
    echo "System Information Report - $(date)"
    echo "============================================"
    echo ""

    # OS and Kernel
    echo "Operating System:"
    if [ -f /etc/debian_version ]; then
        echo "  Debian $(cat /etc/debian_version)"
        lsb_release -a 2>/dev/null | grep -E "Description|Codename" | sed 's/^/  /'
    elif [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "  Distribution: $NAME $VERSION_ID"
    elif [ -f /etc/redhat-release ]; then
        echo "  $(cat /etc/redhat-release)"
    else
        echo "  $(uname -o)"
    fi
    echo "  Kernel: $(uname -r)"
    echo "  Architecture: $(uname -m)"
    echo ""

    # CPU
    echo "Processor:"
    lscpu | grep -E "^Model name|^CPU\(s\)|^Thread|^Core|^Socket|^CPU max|^CPU min" | sed 's/^/  /'
    echo ""

    # Memory
    echo "Memory:"
    free -h | head -2 | sed 's/^/  /'
    echo ""

    # Disk Drives
    echo "Disk Drives:"
    lsblk -o NAME,SIZE,TYPE,MOUNTPOINT,FSTYPE 2>/dev/null | grep -v loop | sed 's/^/  /' || echo "  (lsblk not available)"
    echo ""

    # GPU
    echo "Graphics:"
    if command -v lspci &>/dev/null; then
        lspci | grep -i "VGA\|3D\|Display" | sed 's/^/  /'
    else
        echo "  (install pciutils to see GPU info)"
    fi
    echo ""

    # Network Interfaces
    echo "Network Interfaces:"
    if command -v ip &>/dev/null; then
        ip -brief addr show | sed 's/^/  /'
    elif command -v ifconfig &>/dev/null; then
        ifconfig | grep -E "^[a-z]" | sed 's/^/  /'
    else
        echo "  (no network tools found)"
    fi
    echo ""

    # OpenGL
    echo "OpenGL Version (if available):"
    if command -v glxinfo &>/dev/null; then
        glxinfo | grep "OpenGL version" | sed 's/^/  /'
    else
        echo "  (install mesa-utils to see OpenGL version)"
    fi
    echo ""

    # Additional Hardware (requires sudo)
    if [ "$EUID" -eq 0 ]; then
        echo "System Manufacturer & BIOS:"
        dmidecode -t system 2>/dev/null | grep -E "Manufacturer|Product Name|Version" | sed 's/^/  /' || echo "  (dmidecode not available)"
        dmidecode -t bios 2>/dev/null | grep -E "Vendor|Version|Release Date" | sed 's/^/  /'
    else
        echo "Note: Run as root to include BIOS/system details."
    fi

    echo ""
    echo "============================================"
    echo "Report saved to: $OUTFILE"
} > "$OUTFILE"

# Report completion
echo "Report generated: $OUTFILE"
