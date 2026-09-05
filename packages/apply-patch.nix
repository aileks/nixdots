# Local fixups integrate the expected rejects. Any other result fails the build.
{
  name,
  source,
  fuzz ? 3,
  expectedFailedHunks ? 0,
}:
''
  if patch_output=$(patch -p1 --batch --forward --fuzz=${toString fuzz} \
    --no-backup-if-mismatch --reject-file=- < ${source} 2>&1); then
    patch_status=0
  else
    patch_status=$?
  fi
  printf '%s\n' "$patch_output"
  failed_hunks=$(printf '%s\n' "$patch_output" | awk '
    /Hunk #[0-9]+ FAILED/ { count++ }
    /out of [0-9]+ hunks ignored/ { count += $1 }
    END { print count + 0 }
  ')
  expected_status=${if expectedFailedHunks == 0 then "0" else "1"}
  if [ "$patch_status" -ne "$expected_status" ] || \
    [ "$failed_hunks" -ne ${toString expectedFailedHunks} ]; then
    echo "unexpected patch result for ${name}: status=$patch_status failed_hunks=$failed_hunks" >&2
    exit 1
  fi
''
