#!/bin/bash

# based on gnossen's check_hugo.sh file:
# https://github.com/grpc/grpc.io/blob/main/check_hugo.sh

set -e

command -v hugo >/dev/null || (echo "Hugo extended must be installed on your system." >/dev/stderr; exit 1)
hugo version | grep -i extended >/dev/null || (echo "Your Hugo installation does not appear to be extended." >/dev/stderr; exit 1)

