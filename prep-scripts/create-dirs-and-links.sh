#!/bin/bash

set -e
set -u
set -o pipefail

cd "$HOME"
for dir in "sources" "tools" "cross-tools"; do
    sudo mkdir -pv "/AltimatOS/$dir"
    sudo chmod -v 0775 "/AltimatOS/$dir"
    sudo setfacl -m g:builders:rwx "/AltimatOS/$dir"
    sudo setfacl -dm g:builders:rwx "/AltimatOS/$dir"
    sudo ln -svf "/AltimatOS/$dir" "/$dir"
    ln -svf "/AltimatOS/$dir" "$HOME/$dir"
done

