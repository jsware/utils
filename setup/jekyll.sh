#!/usr/bin/env bash
set -o errexit -o errtrace -o nounset -o pipefail # Robust scripting (-euo pipefail)
origDir="$(pwd)"; cd -P "$(dirname "$0")"; scriptDir="$(pwd)"; scriptName="$(basename "$0")"; utilsDir="$(dirname "$scriptDir")"; cd "$origDir" # Get the script directory

# Help text
if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  cat <<:END
Setup Jekyll
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
echo "Setting up Jekyll..."

echo "Variables:" >&3
echo "  Orig Dir:   $origDir" >&3
echo "  Script Dir: $scriptDir" >&3
echo "  Script Name: $scriptName" >&3
echo "  Utils Dir:  $utilsDir" >&3

echo "Installing Jekyll dependencies..."
sudo apt-get install --yes ruby-full build-essential zlib1g-dev >&3 || die "Failed to install Jekyll dependencies."

echo "Configuring Ruby..."
mkdir -p "$utilsDir/local/gems" || die "Failed to create gem directory."
export GEM_HOME="$utilsDir/local/gems"
export ADDPATH="$GEM_HOME/bin"
$scriptDir/vars.sh GEM_HOME ADDPATH

echo "Installing Jekyll & Bundler..."
gem install jekyll bundler >&3 || die "Failed to install Jekyll & Bundler."

echo "Jekyll setup complete."
