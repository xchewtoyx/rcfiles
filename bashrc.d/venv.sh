function venv {
  VENV=$1
  if [ -z "$VENV" ]; then
    echo 'No environment specified' 1>&2
    return 1
  fi
  if [ -d "$HOME/env/$VENV" ]; then
    if [ -f "$HOME/env/$VENV/bin/activate" ]; then
      source $HOME/env/$VENV/bin/activate
    else
      echo "Activation script not present in environment $1" 1>&2
      return 1
    fi
  else
    echo "Environment $1 not found" 1>&2
    return 1
  fi
}
