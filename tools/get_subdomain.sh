#!/bin/sh

for i in "$@" ; do
    if [[ $i == "sublist3r" ]] ; then
        python3 /app/tools/Sublist3r/sublist3r.py -d $2 -t $1 -o $3/from_sublister.txt
    fi
    if [[ $i == "amass-passive" ]] ; then
        /app/tools/amass enum --passive -d $2 -o $3/fromamass.txt
    fi
    if [[ $i == "amass-active" ]] ; then
        /app/tools/amass enum -active -o $3/fromamass-active.txt -d $2 -brute -w /app/tools/wordlist/deepmagic.com-prefixes-top50000.txt
    fi
    if [[ $i == "assetfinder" ]] ; then
        assetfinder --subs-only $2 > $3/fromassetfinder.txt
    fi
    if [[ $i == "subfinder" ]] ; then
        subfinder -d $2 -t $1 > $3/fromsubfinder.txt
    fi
    if [[ $i == "rapiddns" ]] ; then
        curl -s "https://rapiddns.io/subdomain/$2?full=1#result" | grep "<td><a" | cut -d '"' -f 2 | grep http | cut -d '/' -f3 | sed 's/#results//g' | sort -u > $3/fromrapiddns.txt
    fi
done

cat $3/*.txt > $3/subdomain_collection.txt
rm -rf $3/from*
sort -u $3/subdomain_collection.txt -o $3/sorted_subdomain_collection.txt

rm -rf $3/subdomain*
