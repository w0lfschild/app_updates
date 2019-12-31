#! /bin/bash

_path=$(dirname "$0")
_root=$(dirname $_path)
_file="${_path##*/}"

# Update appcast
"$_root"/bin/generate_appcast "/Users/w0lf/Library/Mobile Documents/com~apple~CloudDocs/dsa_priv.pem" "$_path"

# Push to GitHub
cd "$_path"
cd ../
echo "$PWD"
git pull
git add .
git commit -m "Updated $_file"
git push

# END