#!/usr/bin/env bash
set -o errexit -o errtrace -o nounset -o pipefail # Robust scripting (-euo pipefail)
origDir=`pwd`; cd -P `dirname $0`; scriptDir=`pwd`; utilsDir=`dirname "$scriptDir"`; cd $origDir # Get the script directory

# Help text.
if [[ "${1:-}" = "--help" || "${1:-}" = "-h" ]]; then
  cat <<:END
Setup Arduino IDE V1.8.19
Usage: $0 [Options]

Options:
  -h, --help    Show this help.
  -v, --verbose Verbose output.
  -x, --debug   Debug output.
  -xx, --trace  Trace output.
:END
  exit 0
fi

# Verbose logging
exec 3>/dev/null # Send verbose logging output to dev/null by default

# Exit with a message and exit code
die() {
    local rc=$?
    if [[ $rc > 0 ]]; then
        echo "ERROR: ${*:-Aborting} (RC $rc)" >&2
    else
        echo "ERROR: ${*:-Aborting}" >&2
    fi

    exit $rc
}

# Parse arguments
args=("$@")
for ((arg=0;arg<${#args[@]};arg++)); do
  opt="${args[$arg]:-}"
  param="${args[$((arg+1))]:-}"

  case "$opt" in
    -v|--verbose) exec 3>&2;; # Send verbose output to stderr
    -x|--debug)   set -o verbose;;
    -xx|--trace)  set -o verbose
                  set -o xtrace;;

    --) arg=$((arg+1))
        break;;

    -*) die "Invalid option '$opt' found. Try --help";;

    *)  break;; # End of options
  esac
done
shift $arg

# Verify arguments
if [[ -n "${1:-}" ]]; then
  die "Unexpected argument(s) '$*' found. Try --help."
fi

# Let's go!
echo "Setting up Arduio IDE V1.8.19..."

echo "Variables:" >&3
echo "  Orig Dir:   $origDir" >&3
echo "  Script Dir: $scriptDir" >&3
echo "  Utils Dir:  $utilsDir" >&3

echo "Downloading Arduino IDE V1.8.19..."
cd /tmp
curl -sSL https://downloads.arduino.cc/arduino-1.8.19-linux64.tar.xz -o arduino-1.8.19-linux64.tar.xz || die "Failed to download Arduino IDE V1.8.19"
mkdir -p "$utilsDir/local" || die "Failed to create $utilsDir/local"
cd "$utilsDir/local"
tar xvf /tmp/arduino-1.8.19-linux64.tar.xz >&3 || die "Failed to extract Arduino IDE V1.8.19"
rm /tmp/arduino-1.8.19-linux64.tar.xz || die "Failed to remove /tmp/arduino-1.8.19-linux64.tar.xz"

echo "Installing Arduino IDE V1.8.19..."
sudo arduino-1.8.19/install.sh || die "Failed to install Arduino IDE V1.8.19"
arduino-1.8.19/arduino-linux-setup.sh $USER || die "Failed to run arduino-linux-setup.sh"

echo "Arduino IDE V1.8.19 setup completed."
