FROM registry.opensuse.org/opensuse/distrobox:latest

# Set nvim as editor
ENV VISUAL nvim
ENV EDITOR $VISUAL

# Configure less
ENV LESS "--clear-screen --RAW-CONTROL-CHARS --tabs 2 --mouse"

# Run tmux session named dev when container starts
ENTRYPOINT ["tmux"]
CMD ["new-session", "-A", "-s", "dev"]

# Get list of required packages
# Lines are joined by a space, Lines beginning with # are ignored
COPY requirements.txt /tmp/requirements.txt
# Add Packages and remove directories used by zypper that are just taking up space
RUN --mount=type=cache,target=/var/cache \
    zypper refresh \
    && zypper install --no-recommends --no-confirm $(grep -v '^#' /tmp/requirements.txt | tr "\n" " ") \
    && npm install --global --cache=/var/cache/npm pyright \
    && ln --symbolic $(which python3) /usr/local/bin/python \
    && ruff generate-shell-completion zsh > usr/share/zsh/site-functions/_ruff

# Add useful scripts
COPY scripts /usr/local/bin/

# Add editorconfig to created user accounts
COPY .editorconfig /etc/skel

# Add tmux config files
COPY tmux/.tmux.conf /etc/tmux.conf
COPY tmux/.tmux.conf.local /etc/tmux.conf.local

# Add zsh config files
COPY --chown=root:root --chmod=644 zsh/functions /usr/local/share/zsh/site-functions

COPY zsh/plugins/zsh-history-substring-search/zsh* \
    /usr/local/share/zsh/site-plugins/zsh-history-substring-search/

COPY zsh/plugins/zsh-syntax-highlighting/zsh* \
     zsh/plugins/zsh-syntax-highlighting/.revision-hash	\
     zsh/plugins/zsh-syntax-highlighting/.version	\
    /usr/local/share/zsh/site-plugins/zsh-syntax-highlighting/
COPY zsh/plugins/zsh-syntax-highlighting/highlighters	\
    /usr/local/share/zsh/site-plugins/zsh-syntax-highlighting/highlighters/

COPY zsh/themes /usr/local/share/zsh/site-themes/

COPY zsh/zshenv zsh/p10k.zsh /etc
COPY zsh/zshrc /etc/zsh.zshrc.local

# Set up neovim
COPY nvim/sysinit.vim /etc/xdg/nvim/sysinit.vim
COPY nvim/lua /etc/xdg/nvim/lua/
COPY nvim/coc-settings.json /etc/skel/.config/nvim/coc-settings.json

# vim: set ft=dockerfile:
