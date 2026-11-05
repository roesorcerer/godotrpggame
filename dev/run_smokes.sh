#!/usr/bin/env bash
# Runs every dev/*_smoke.tscn headless and reports pass/fail for each.
# Exits 0 only if all of them pass.
#
#   ./dev/run_smokes.sh            # from the project root, in Git Bash
#   GODOT=/path/to/godot ./dev/run_smokes.sh
#
# Each smoke scene calls get_tree().quit(0) on pass and quit(1) on fail.
# A test that hasn't quit after SMOKE_TIMEOUT seconds counts as a failure.

cd "$(dirname "$0")/.." || exit 1

SMOKE_TIMEOUT="${SMOKE_TIMEOUT:-120}"

# Godot binary: $GODOT if set, else `godot` on PATH, else the local install.
if [ -z "$GODOT" ]; then
	if command -v godot >/dev/null 2>&1; then
		GODOT=godot
	else
		GODOT="/c/Program Files/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2.exe"
	fi
fi
if ! command -v "$GODOT" >/dev/null 2>&1 && [ ! -x "$GODOT" ]; then
	echo "Can't find Godot at '$GODOT'. Set GODOT=/path/to/godot and rerun." >&2
	exit 2
fi

passed=()
failed=()

for scene in dev/*_smoke.tscn; do
	name="$(basename "$scene" .tscn)"
	log="$(mktemp)"
	timeout "$SMOKE_TIMEOUT" "$GODOT" --headless --path . "res://$scene" >"$log" 2>&1
	code=$?
	if [ "$code" -eq 0 ]; then
		echo "PASS  $name"
		passed+=("$name")
	else
		if [ "$code" -eq 124 ]; then
			echo "FAIL  $name (timed out after ${SMOKE_TIMEOUT}s)"
		else
			echo "FAIL  $name (exit $code)"
		fi
		# Show the lines that explain the failure.
		grep -E "SMOKE|FAIL|ERROR|SCRIPT ERROR|Parse Error" "$log" | sed 's/^/      /' | head -20
		failed+=("$name")
	fi
	rm -f "$log"
done

echo
echo "${#passed[@]} passed, ${#failed[@]} failed"
[ "${#failed[@]}" -eq 0 ]
