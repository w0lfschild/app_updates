#! /bin/bash

plistbud () {
	/usr/libexec/PlistBuddy -c "$@"
}

if [[ "$1" != "" ]]; then
	# Recieved cDock file
	appCast="$HOME/GitHub/wb_appUpdates/cDock/appcast.xml"
	fldr=$(dirname "$1")
	prgm=$(basename "$1")
	prgm=${prgm%.*}
	size=0

	# Unzip
	pushd "$fldr"/
	unzip "$1"
	# ditto -ck --rsrc --sequesterRsrc --keepParent "$prgm".app "$zipPath"
	popd

	# zipPath="$fldr"/"$prgm"_"$vernum".zip
	zipPath="$1"
	appPath="$fldr"/"$prgm".app
	plistPath="$appPath"/Contents/Info.plist
	vernum=$(plistbud "Print CFBundleShortVersionString" "$plistPath")
	verlon=$(plistbud "Print CFBundleVersion" "$plistPath")
	resFile="$prgm"_"$vernum".zip

	# Hash
	myHash=$(sign_update "$zipPath" "$HOME/Library/Mobile Documents/com~apple~CloudDocs/dsa_priv.pem")

	# Size
	mySize=$(wc -c "$zipPath" | cut -d" " -f2)
	# mySize=$(wc -c "$1" | cut -d" " -f2)

	# Move
	mv "$zipPath" "$HOME/GitHub/wb_appUpdates/cDock/$resFile"

	# Trash
	trashman "$appPath"

	# Update appcast
	pubDate=$(date)
	sed -i -e "s/.*pubDate.*/            <pubDate>$pubDate<\/pubDate>/" "$appCast"
	sed -i -e "s/.*enclosure.*/            <enclosure url=\"https:\/\/github.com\/w0lfschild\/app_updates\/raw\/master\/cDock\/$resFile\"/" "$appCast"
	sed -i -e "s/.*sparkle:version=.*/            sparkle:version=\"$vernum\"/" "$appCast"
	sed -i -e "s/.*sparkle:shortVersionString=.*/            sparkle:shortVersionString=\"$verlon\"/" "$appCast"
	sed -i -e "s/.*length=.*/            length=\"$mySize\"/" "$appCast"
	sed -i -e "s/.*sparkle:dsaSignature=.*/            sparkle:dsaSignature=\"$myHash\" \/>/" "$appCast"

	# open -e "$appCast"

	# Print
	clear
	printf '\e[3J'
	echo "File:    $1"
	echo "Result:  $resFile"
	echo "Size:    $mySize"
	echo "Hash:    $myHash"
	echo "Zip:     $zipPath"
	echo "Plist:   $plistPath"
	echo "Folder:  $fldr"
	echo "Program: $prgm"
	echo "Short:   $vernum"
	echo "Long:    $verlon"
fi

#END