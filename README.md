# virt-manager on OSX

`docker run --rm steigr/virt-manager start | bash`

## Installation

First install `XQuartz` and `socat` and (at least) relogin.

The add the following to your `.bashrc` or `.zshrc` ( or whatever ): `virt-manager() { docker run --rm steigr/virt-manager start | exec bash; }`

## Service

SSH_AUTH_AGENT and X11-Socket are forwarded into the container. You may log into every host you may login from your OSX/macOS machine.