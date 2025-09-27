#!/usr/bin/env bash
set -o errexit -o errtrace -o nounset -o pipefail # Robust scripting (-euo pipefail)
origDir=`pwd`; cd -P `dirname $0`; scriptDir=`pwd`; utilsDir=`dirname "$scriptDir"`; cd $origDir # Get the script directory

# Help text.
if [[ "${1:-}" = "--help" || "${1:-}" = "-h" ]]; then
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
    -v|--verbose) vbse="--verbose"; exec 3>&2;; # Send verbose output to stderr
    -x|--debug)   dbug="--debug";   set -o verbose;;
    -xx|--trace)  trce="--trace";   set -o verbose
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
  setupScripts=$*
fi

# Let's go!
echo "Setting up all utilities..."

echo "Variables:" >&3
echo "  Orig Dir:   $origDir" >&3
echo "  Script Dir: $scriptDir" >&3
echo "  Utils Dir:  $utilsDir" >&3
echo "  Verbose:    ${vbse:=}" >&3
echo "  Debug:      ${dbug:=}" >&3
echo "  Trace:      ${trce:=}" >&3
echo "  Scripts:    ${setupScripts:=$scriptDir/*.sh}" >&3

for setup in $setupScripts; do
  if [[ $setup == $scriptDir/all.sh ]]; then
    echo "Skipping self '$setup'..." >&3
  elif [[ ! -x "$setup" ]]; then
    echo "Skipping non-executable script '$setup'..." >&3
  else
    echo "Running setup script '$setup'..." >&3
    "$setup" $vbse $dbug $trce || die "Setup script '$setup' failed."
  fi
done

echo "All setup complete."
