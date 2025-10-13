#!/usr/bin/env bash
if [ -z "${BASH_VERSION:-}" ]; then
  # Fail fast if not bash (Use [] in case POSIX).
  echo 'Bash is required to interpret this script.' >&2
  echo 'Use: /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/jsware/utils/HEAD/install.sh)"' >&2
  exit 1
fi
set -o errexit -o errtrace -o nounset -o pipefail # Robust scripting (-euo pipefail)
origDir=`pwd`; cd -P `dirname $0`; scriptDir=`pwd`; cd $origDir # Get the script directory

# Help text.
if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  cat <<:END
Install jsware/utils
Usage: ${0##*/} [Options]
  
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
echo "Installing jsware/utils..."

echo "Variables:" >&3
echo "  Orig Dir:    $origDir" >&3
echo "  Script Dir:  $scriptDir" >&3
echo "  Script Name: $scriptName" >&3

if [[ -z "$(which git)" ]]; then
  echo "Installing git..."
  sudo apt-get install git -y >&3 || die "Failed to install git."
fi

if [[ "$(pwd)" == "$scriptDir" ]]; then
  echo "Updating existing jsware/utils repository..."
  git pull || die "Failed to update existing jsware/utils repository."
else
  echo "Cloning jsware/utils repository..."
  git clone https://github.com/jsware/utils.git || die "Failed to clone jsware/utils repository."
  cd ./utils || die "Failed to change directory to ./utils after cloning it."
fi

echo "Installing jsware/utils complete."
