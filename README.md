# Development Environment
A set up for a development environment centred on tmux (terminal multiplexer), zsh (shell), neovim (text editor), ranger (file manager).
Other handy utilities are also included, see requirements.txt for the packages added to a Fedora base.



## As a Container
The development environment can be run as a container.
The tested approach is to use docker-compose.
To build the container image run: `make image`.
To start a container from the created image run `make container`.


For easy starting from any directory run `make bin` to put `devenv` in `~/.local/bin`.
A container can then be started by calling `devenv`.
`devenv` is a soft link to the script called by `make container`.


If running as above (without any modifications to the docker compose file), then only two locations will be persistent (attached volumes) /home/developer/projects (for your work) and /home/developer/.local/share (for application data).
The host users home directory will also be accessible if needed, it will be mounted in the same location as on the host machine.



### Troubleshooting

#### SSH
If the host is Mac OS you may need to add `IgnoreUnknown UseKeychain` to `~/.ssh/config` for SSH to work.



## Local Install
A script to set up the environment for the local user can be produced from the container definition file (Containerfile) by running `make install.sh`.
The produced `install.sh` script should work for recent versions of Fedora, but may need modifying for other distributions / operating systems.



## Miscellaneous

### Fonts
Nerd fonts are recommended to get the most from zsh theme, see [here](https://www.nerdfonts.com/).



### Terminal Colors
The setup is designed for the following terminal colors:

| Name                |       Hex |
| ------------------- | ---------:|
| background-color    |   #282C34 |
| foreground-color    |   #ABB2BF |
| black               |   #1F2229 |
| red           	    |   #E06C75 |
| green               |   #98C379 |
| yellow              |   #D19a66 |
| blue                |   #61AFEF |
| magenta             |   #C678DD |
| cyan                |   #56B6C2 |
| white               |   #ABB2BF |
| bright-black        |   #3E4452 |
| bright-red          |   #E06C75 |
| bright-green        |   #98C379 |
| bright-yellow       |   #E5C07B |
| bright-blue         |   #61AFEF |
| bright-magenta      |   #C678DD |
| bright-cyan         |   #56B6C2 |
| bright-white        |   #DDE0E5 |
