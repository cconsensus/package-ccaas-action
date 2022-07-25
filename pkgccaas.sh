#!/bin/sh -l

usage() {
    echo "Usage: pkgccaas.sh -l <label> -n <name> -d <address> [-m <META-INF directory>]"
    echo
    echo "  Creates a ccaas chaincode package"
    echo
    echo "    Flags:"
    echo "    -l <label> - chaincode label"
    echo "    -n <name> - docker image name"
    echo "    -a <address> - chaincode address eg.: '{{.peername}}-ccaas-<cc_name>:9999'"
    echo "    -m <META-INF directory> - state database index definitions for CouchDB"
    echo "    -h - Print this message"
}

error_exit() {
    echo "${1:-"Unknown Error"}" 1>&2
    exit 1
}

while getopts "hl:n:a:m:" opt; do
    case "$opt" in
        h)
            usage
            exit 0
            ;;
        l)
            label=${OPTARG}
            ;;
        n)
            name=${OPTARG}
            ;;
        a)
            address=${OPTARG}
            ;;
        m)
            metainf=${OPTARG}
            ;;
        *)
            usage
            exit 1
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "$label" ] || [ -z "$name" ] || [ -z "$address" ]; then
    usage
    exit 1
fi

if [ -n "$metainf" ]; then
    metadir=$(basename "$metainf")
    if [ "META-INF" != "$metadir" ]; then
        error_exit "Invalid chaincode META-INF directory $metainf: directory name must be 'META-INF'"
    elif [ ! -d "$metainf" ]; then
        error_exit "Cannot find directory $metainf"
    fi
fi

prefix=$(basename "$0")
tempdir=$(mktemp -d -t "$prefix.XXXXXXXX") || error_exit "Error creating temporary directory"

if [ -n "$DEBUG" ]; then
    echo "label = $label"
    echo "name = $name"
    echo "address = $address"
    echo "metainf = $metainf"
    echo "tempdir = $tempdir"
fi

mkdir -p "$tempdir/src"
cat << CONNECTION-EOF > "$tempdir/src/connection.json"
{
  "address": "$address",
  "dial_timeout": "10s",
  "tls_required": false
}
CONNECTION-EOF

if [ -n "$metainf" ]; then
    cp -a "$metainf" "$tempdir/src/"
fi

mkdir -p "$tempdir/pkg"
cat << METADATAJSON-EOF > "$tempdir/pkg/metadata.json"
{
    "type": "ccaas",
    "label": "$label"
}
METADATAJSON-EOF

tar -C "$tempdir/src" -czf "$tempdir/pkg/code.tar.gz" .

tar -C "$tempdir/pkg" -czf "$label.tgz" metadata.json code.tar.gz

rm -Rf "$tempdir"
