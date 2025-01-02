# Development Environment

A set up for a development environment centred on tmux (terminal multiplexer), zsh (shell), neovim (text editor), ranger (file manager).
Other handy utilities are also included, see requirements.txt for the packages added to an openSUSE Tumbleweed base.

![Shell Screenshot](screenshots/shell.png)

## Using Distrobox

The image can be built using `./build image`.
To create the distrobox container `./build container`.

Note: `./build` is equivalent to `./build image container`.

To enter the distrobox container run `./build enter`, `distrobox enter devenv`,
or launch it from the system application launcher.

The devenv's home directory is a `devenv` directory in the host user's home directory.
The host users home directory will also be accessible if needed,
it will be mounted in the container at the same path as on the host machine.

If files from the host user's home need to be shared with the container user,
a symbolic link should be used.
For example, from inside the container run `ln --symbolic $DISTROBOX_HOST_HOME/.config/git ~/.config/`
to share git configuration.

### Troubleshooting

#### SSH

If the host is Mac OS you may need to add `IgnoreUnknown UseKeychain` to `~/.ssh/config` for SSH to work.

## WSL Install

To build the image (devenv.wsl) run `./build pull image wsl` on a machine with `podman` installed.

Note: an openSUSE Tubleweed WSL image, which can be used for the build, is available in the Microsoft store.

The WSL distribution can be installed by double clicking on the `wsl` file in windows explorer.
Alternatively, it can be installed with `wsl --install --from-file (path to devenv.wsl)`.

### First Run

To perform the required initial setup:
- From powershell run: `wsl --distribution devenv`.
- The initial setup script will run automatically, follow the instructions.

### Optional Steps

The default WSL distribution can be set to devenv using `wsl --setdefault devenv`.

### Backup and Restore

An archive of the WSL distribution's file system can be created with:
`wsl --export devenv devenv_backup.tar`.
This archive will include any keys, tokens, passwords, etc. which are stored,
so make sure to store it securely.

The backup can be imported with: `wsl --import devenv devenv devenv_backup.tar`.
If replacing a broken WSL distribution (rather than migrating to a new machine),
you may first have to remove the old one:
`wsl --terminate devenv; wsl --unregister devenv`,
then rename the install directory for that distribution.

### Migrating Data

Data can be migrated from the virtual drive of another WSL distribution or virtual machine.

To mount the virtual drive, run the following in Powershell with admin rights:
`wsl --mount --vhd (path to vhdx file) --name (mount name)`.

As an example, to migrate a user home directory run the following from inside the devenv WSL distribution:
`rsync -aP /mnt/wsl/(mount name)/$HOME/ $HOME`.
Note: This assumes the user home path is the same in both installs.

To unmount the virtual drive, run the following in Powershell:
`wsl --unmount (path to vhdx file)`.

If migrating data from a previous devenv install:
- Copy the virtual drive for the old install.
- Unregister the old install with `wsl --unregister devenv` (this will delete the virtual drive, but not the copy).
- Follow the above to install the new devenv image and migrate the data.

Note: if the old devenv is not unregistered,
a different name will have to be set via the WSL CLI on install of the distribution.

## Maintenance

Periodic OS updates should be performed using `sudo zypper dup` (`dup` is short for `dist-upgrade`).

## Included Scripts

- setup_git.sh: configure git with user info and some customisation.
- install_python_dev_tools.sh: installs common Python development tools, including recent Python versions.
- install_vscode.sh: installs VSCode inside the running distrobox and exposes it to the host.

## Miscellaneous

### Fonts

Nerd fonts are recommended to get the most from zsh theme, see [here](https://www.nerdfonts.com/).

### Terminal Colors

The setup is designed for the following terminal colors:

| Name                |       Hex |
| ------------------- | ---------:|
| background-color    |   #282C34 |
| foreground-color    |   #A7AAB0 |
| black               |   #101012 |
| red                 |   #DE5D68 |
| green               |   #8FB573 |
| yellow              |   #DBB671 |
| blue                |   #57A5E5 |
| magenta             |   #BB70D2 |
| cyan                |   #51A8B3 |
| white               |   #ABB2BF |
| bright-black        |   #5C6370 |
| bright-red          |   #DE5D68 |
| bright-green        |   #8FB573 |
| bright-yellow       |   #DBB671 |
| bright-blue         |   #57A5E5 |
| bright-magenta      |   #BB70D2 |
| bright-cyan         |   #51A8B3 |
| bright-white        |   #FFFEFE |
