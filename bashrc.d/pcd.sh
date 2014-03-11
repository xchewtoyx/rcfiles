function pcd {
  python<<-EOC
	import sys
	try:
	  import $1
	except ImportError:
	  sys.exit(1)
EOC
  if [ "$?" -ne "0" ]; then
    echo "Can't load module $1" 1>&2
    return 1
  fi
  cd $(python -c "import os,$1; print os.path.dirname($1.__file__)")
}
