#!/bin/bash

find /home -type f -exec du -h {} + 2>/dev/null | sort -hr | head -n 5
