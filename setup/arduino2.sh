#!/usr/bin/env bash
set -o errexit -o errtrace -o nounset -o pipefail # Robust scripting (-euo pipefail)
origDir="$(pwd)"; cd -P "$(dirname "$0")"; scriptDir="$(pwd)"; scriptName="$(basename "$0")"; utilsDir="$(dirname "$scriptDir")"; cd "$origDir" # Get the script directory

# Help text
if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  cat <<:END
Setup Arduino IDE V2.3.6
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
echo "Setting up Arduino IDE V2.3.6..."

echo "Variables:" >&3
echo "  Orig Dir:    $origDir" >&3
echo "  Script Dir:  $scriptDir" >&3
echo "  Script Name: $scriptName" >&3
echo "  Utils Dir:   $utilsDir" >&3

echo "Downloading Arduino IDE V2.3.6..."
cd /tmp
curl -sSL https://downloads.arduino.cc/arduino-ide/arduino-ide_2.3.6_Linux_64bit.zip -o arduino-ide_2.3.6_Linux_64bit.zip || die "Failed to download Arduino IDE 2.3.6"
mkdir -p "$utilsDir/local" || die "Failed to create $utilsDir/local"
cd "$utilsDir/local"

echo "Installing Arduino IDE V2.3.6..."
unzip -o /tmp/arduino-ide_2.3.6_Linux_64bit.zip >&3 || die "Failed to extract Arduino IDE V2.3.6"
rm -fr arduino-2.3.6 || die "Failed to remove old Arduino IDE V2.3.6 directory"
mv arduino-ide_2.3.6_Linux_64bit arduino-2.3.6 || die "Failed to rename Arduino IDE V2.3.6 directory"
rm /tmp/arduino-ide_2.3.6_Linux_64bit.zip || die "Failed to remove temporary Arduino IDE V2.3.6 zip file"

echo "Creating desktop entry..."
cd "/tmp"
UTILS_LOCAL_DIR="$utilsDir/local" $scriptDir/helpers/mo "$scriptDir/helpers/arduino-ide.desktop" >arduino-ide.desktop || die "Failed to create desktop entry."
chmod 644 arduino-ide.desktop || die "Failed to chmod desktop entry."
sudo chown root:root arduino-ide.desktop || die "Failed to chown desktop entry."
sudo mv arduino-ide.desktop /usr/share/applications || die "Failed to move desktop entry."

echo "Configuring udev..."
sudo bash -c "$( curl -fsSL https://raw.githubusercontent.com/arduino/ArduinoCore-mbed/HEAD/post_install.sh )" || die "Failed to configure udev."

echo "Arduino setup completed."
