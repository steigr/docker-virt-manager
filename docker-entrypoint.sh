#!/usr/bin/env bash

set -eo pipefail
[[ -z "$TRACE" ]] || set -x

vars() {
	export SSH_AUTH_SOCK=/tmp/ssh-auth-sock	
}

_start() {
	exec cat<<'_start'
#!/usr/bin/env bash

set -eo pipefail
[[ -z "$TRACE" ]] || set -x

vars() {
	true
}

fail() {
	echo "$@"
	exit 1
}

check_tool() {
	tool=$1; shift
	command -v "$tool" >/dev/null || fail "Please install $tool first!"
}

set_local_ip() {
	XIP=$(ifconfig en0 | grep "inet " | awk '{print $2}')
}

forward_x_over_ip() {
	XDISPLAY=$(( RANDOM % 512 ))
	XPORT=$(( 6000 + XDISPLAY ))
	socat TCP-LISTEN:$XPORT,reuseaddr,fork UNIX-CLIENT:\"$DISPLAY\" &
	XDISPLAY_PID=$!

}

forward_sshagent_over_ip() {
	XSSH=$(( 7000 + XDISPLAY ))
	socat TCP-LISTEN:$XSSH,reuseaddr,fork UNIX-CLIENT:\"$SSH_AUTH_SOCK\" &
	XSSH_PID=$!
}

install_trap() {
	trap "kill $XSSH_PID $XDISPLAY_PID" EXIT	
}

run_virtmanager() {
	docker run \
	--rm \
	--volume=$HOME/.ssh:/root/.ssh \
	--volume=$HOME/.config:/root/.config \
	--env=TRACE \
	--env=DISPLAY=$XIP:$XDISPLAY \
	--env=SSH_AGENT_SOCKET=$XIP:$XSSH \
	steigr/virt-manager run
}

main() {
	check_tool ifconfig
	check_tool socat
	check_tool grep
	check_tool awk
	set_local_ip
	forward_x_over_ip
	forward_sshagent_over_ip
	install_trap
	run_virtmanager
}

vars
main  "$@"
_start
}

_run() {
	rm "$0"
	start-stop-daemon -S -x /usr/bin/socat -b -- UNIX-LISTEN:$SSH_AUTH_SOCK,fork TCP:$SSH_AGENT_SOCKET
	exec virt-manager --no-fork
}

main() {
	cmd=$1
	[[ "$#" -le 0 ]] || shift
	[[ "$cmd" != "run"   ]] || _run "$@"
	[[ "$cmd" != "start" ]] || _start "$@" 
	exec "$cmd" "$@"
}

vars
main "$@"