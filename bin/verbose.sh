# Enable verbose logging: v_on [fd]
v_on() {
  if [ $# -gt 0 ]; then
    exec 3>&$1
  else
    exec 3>&2
  fi
}

# Disable verbose logging: v_off
v_off() {
  exec 3>/dev/null
}

# By default, turn verbose logging off
v_off

# Verbose echo v_echo "Message Text"
v_echo() {
  local rc=$?
  if [ $rc -gt 0 ]; then
    echo "$* (RC $rc)" >&3
  else
    echo "$*" >&3
  fi
}

# Verbose variable: v_var [displayName] varName
# If only one argument is given, displayName = varName
v_var() {
  if [ -z "$BASH_VERSION" -o -n "${POSIXLY_CORRECT+1}" ]; then
    if [ $# -lt 2 ]; then
      eval vval="\${$1:-<<undefined>>}"
    else
      eval vval="\${$2:-<<undefined>>}"
    fi
    echo "$1 = \"$vval\"" >&3
  else
    if [ $# -lt 2 ]; then
      echo "$1 = \"${!1:-<<undefined>>}\"" >&3
    else
      echo "$1 = \"${!2:-<<undefined>>}\"" >&3
    fi
  fi
}
