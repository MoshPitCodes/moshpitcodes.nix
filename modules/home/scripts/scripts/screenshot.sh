dir="$HOME/Pictures/Screenshots"

if [[ ! -d "$dir" ]]; then
	mkdir -p "$dir"
fi

case "${1:-}" in
--copy)
	grimblast --freeze --wait 0.2 --notify copy area
	;;
--save)
	grimblast --freeze --wait 0.2 --notify copysave area "$dir/$(date +%Y-%m-%d_%H-%M-%S).png"
	;;
--full)
	grimblast --notify copy screen
	;;
*)
	grimblast --notify copy area
	;;
esac
