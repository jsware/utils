#!/usr/bin/env bash
set -o errexit -o errtrace -o nounset -o pipefail # Robust scripting (-euo pipefail)
origDir=`pwd`; cd -P `dirname $0`; scriptDir=`pwd`; utilsDir=`dirname "$scriptDir"`; cd $origDir # Get the script directory

# Help
if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  cat <<:END
Setup Environment Variables.
Usage: $0 [Options] VarName...

Arguments:
  VarName...  One or more variable names to set up.

Options:
  -d, --dotFile The dotFile to use. Default is ~/.bashrc
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
for ((arg=0; arg < ${#args[@]}; arg++)); do
  opt="${args[$arg]:-}"
  param="${args[$((arg+1))]:-}"

  case "$opt" in
    -d|--dotfile)
        if [[ -z "$param" || "$param" == -* ]]; then
          die "The --dotFile option requires a non-empty argument."
        fi
        dotFile="$param"
        arg=$((arg+1));;

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
  envVars=$*
fi

# Default variables
echo "Variables:" >&3
echo "  Orig Dir:   $origDir" >&3
echo "  Script Dir: $scriptDir" >&3
echo "  Utils Dir:  $utilsDir" >&3
echo "  Env Vars:   ${envVars:=PATH}" >&3
echo "  Dot File:   ${dotFile:=.bashrc}" >&3

echo "Using '$dotFile' to set $envVars..."
if [ ! -f "$HOME/$dotFile" ]; then
  touch "$HOME/$dotFile" || die "Failed to create '$dotFile'."
fi

for var in $envVars; do
  case "$var" in
    PATH)
      mkdir -p "$utilsDir/local/bin" || die "Failed to create '$utilsDir/local/bin'."

      echo "PATH=\"$utilsDir/bin:$utilsDir/local/bin:\$PATH\"" >&3
      grep -qE "PATH=.*$utilsDir/local/bin:.*" "$HOME/$dotFile" || echo "export PATH=\"$utilsDir/local/bin:\$PATH\"" >>"$HOME/$dotFile" || die "Failed to update '$dotFile'."
      grep -qE "PATH=.*$utilsDir/bin:.*" "$HOME/$dotFile" || echo "export PATH=\"$utilsDir/bin:\$PATH\"" >>"$HOME/$dotFile" || die "Failed to update '$dotFile'."
      ;;

    ADDPATH)
      echo "PATH=\"${!var}:\$PATH\"" >&3
      grep -qE "PATH=.*${!var}:.*" "$HOME/$dotFile" || echo "export PATH=\"${!var}:\$PATH\"" >>"$HOME/$dotFile" || die "Failed to update '$dotFile'."
      ;;

    *)
      echo "$var=\"${!var}\"" >&3
      grep -qE "$var=\"${!var}\"" "$HOME/$dotFile" || echo "export $var=\"${!var}\"" >>"$HOME/$dotFile" || die "Failed to update '$dotFile'."
      ;;
  esac
done