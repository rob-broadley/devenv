FROM fedora:34

# Set image labels
LABEL version="34.0.0"

# Set name of user to create and location of their home directory
ARG USER="developer"
ARG USER_HOME="/home/$USER"
ARG HOST_DOCKER_GID=""

# Create env var with distro for convenience
ENV DISTRO fedora

# Set term type so tmux theme works properly
ENV TERM xterm-256color

# Set nvim as editor
ENV VISUAL nvim
ENV EDITOR $VISUAL

# XDG Directory Specification
ENV XDG_DATA_HOME $USER_HOME/.local/share
ENV XDG_CONFIG_HOME $USER_HOME/.config
ENV XDG_CACHE_HOME $USER_HOME/.cache

# Set locations of time/task warrior configurations
ENV TASKRC $XDG_CONFIG_HOME/task/taskrc
ENV TIMEWARRIORDB $XDG_CONFIG_HOME/timewarrior

# Run tmux session named dev when container starts
ENTRYPOINT ["tmux"]
CMD ["new-session", "-A", "-s dev"]

# Create docker group with same gid as host docker group
# Will do nothing unless HOST_DOCKER_GID argument is given
RUN [ -z "$HOST_DOCKER_GID" ] || groupadd -g "$HOST_DOCKER_GID" docker

# Change dnf configuration to include docs (e.g. man pages)
RUN sed -i "/^tsflags=nodocs/ c#tsflags=nodocs" /etc/dnf/dnf.conf
# Install man packages
RUN dnf install -y man-db man-pages

# Update packages
RUN dnf update -y

# Get list of required packages
# Lines are joined by a space, Lines beginning with # are ignored
COPY requirements.txt /tmp/requirements.txt
# Add Packages
RUN dnf install -y $(grep -v '^#' /tmp/requirements.txt | tr "\n" " ")

# Add Extras using language specific package managers
RUN npm install --global pyright

# Remove default zshrc from skel so user does not inherit it
RUN rm -f /etc/skel/.zshrc

# Creating user without password and with root privileges.
RUN adduser --groups wheel,docker "$USER"

# Give password-less sudo. This is only acceptable as it is a private
# development environment not exposed to the outside world.
# Do NOT do this on your host machine or otherwise.
RUN echo '%wheel ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Set user name inside container
USER "$USER"

# This will determine where we will start when we enter the container.
WORKDIR "$USER_HOME"

# Add tmux config files
COPY tmux/.tmux.conf $XDG_CONFIG_HOME/tmux/tmux.conf
COPY tmux/.tmux.conf.local $XDG_CONFIG_HOME/tmux/tmux.conf.local

# Add zsh config files
COPY zsh $XDG_CONFIG_HOME/zsh

# Add gitstatusd for powerlevel10k
COPY extras/gitstatusd-linux-x86_64 $XDG_CACHE_HOME/gitstatus/

# Add nvim config files
COPY nvim/init.vim $XDG_CONFIG_HOME/nvim/init.vim
COPY nvim/coc-settings.json $XDG_CONFIG_HOME/nvim/coc-settings.json
COPY nvim/dein.vim $XDG_DATA_HOME/nvim/dein/repos/github.com/Shougo/dein.vim

# Add editorconfig
COPY .editorconfig $XDG_CONFIG_HOME/editorconfig

# Add task and time warrior config files
COPY taskwarrior/taskrc $TASKRC
COPY taskwarrior/timewarrior.cfg $TIMEWARRIORDB/

# Add useful scripts
COPY scripts .local/bin

# Ensure container user home is owned by container user
RUN sudo chown -R "$USER":"$USER" .

# Set up user directories
RUN mkdir -p projects

### BEGIN local_setup
# Ensure cache directory exists
RUN mkdir -p $XDG_CACHE_HOME

# Set up symlinks for tmux config (cannot set where tmux looks [v3.1 may change this])
RUN ln -s $XDG_CONFIG_HOME/tmux/tmux.conf .tmux.conf
RUN ln -s $XDG_CONFIG_HOME/tmux/tmux.conf.local .tmux.conf.local

# Set up symlink for zshenv (must be in user home)
RUN ln -s $XDG_CONFIG_HOME/zsh/zshenv .zshenv
# Ensure zsh data directory exists
RUN mkdir -p $XDG_DATA_HOME/zsh

# Set up symlink for editorconfig
RUN ln -s $XDG_CONFIG_HOME/editorconfig .editorconfig

# Ensure timewarrior data directory exists
RUN mkdir -p $XDG_DATA_HOME/timewarrior
# Set up symlink to where timew expects to find data
# timew currently doesn't allow setting different locations for config and data
RUN ln -s $XDG_DATA_HOME/timewarrior $TIMEWARRIORDB/data

# Set up nvim plugins
RUN nvim --headless -c "call dein#install()" +qa
RUN nvim --headless -c ":CocInstall -sync coc-pyright" +qa

# Set up taskwarrior on-modify hook for timewarrior
RUN mkdir -p $XDG_DATA_HOME/task/hooks
RUN cp /usr/share/doc/timew/ext/on-modify.timewarrior $XDG_DATA_HOME/task/hooks/
RUN sed -i '1 i #!/usr/bin/env python3' $XDG_DATA_HOME/task/hooks/on-modify.timewarrior
RUN chmod +x $XDG_DATA_HOME/task/hooks/on-modify.timewarrior
### END local_setup

# vim: set ft=dockerfile:
