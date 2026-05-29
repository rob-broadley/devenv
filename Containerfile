FROM registry.opensuse.org/opensuse/distrobox:latest

# Set nvim as editor
ENV VISUAL nvim
ENV EDITOR $VISUAL

# Configure less
ENV LESS "--clear-screen --RAW-CONTROL-CHARS --tabs 2 --mouse"

# Set colour scheme for ranger preview syntax highlighting.
ENV PYGMENTIZE_STYLE "one-dark"

# tmux defaults to /run/tmux/<uid>/ for its socket, but /run is a tmpfs
# remounted fresh on each container start so the directory never exists.
# Redirect to /tmp which is always available.
ENV TMUX_TMPDIR /tmp

# Run tmux session named dev when container starts
ENTRYPOINT ["tmux"]
CMD ["new-session", "-A", "-s", "dev"]

# Get list of required packages
# Non-comment lines are passed as separate arguments to zypper via xargs.
COPY requirements.txt /tmp/requirements.txt
# Add Packages and remove directories used by zypper that are just taking up space
RUN --mount=type=cache,target=/var/cache \
    zypper refresh \
    && grep -v '^#' /tmp/requirements.txt | xargs -r zypper install --no-recommends --no-confirm

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
# Fetch Tree-sitter query files (highlights, indent, fold, injections, etc.)
# for all languages from the nvim-treesitter query corpus (queries/ only — no Lua runtime fetched).
# The archived repo is permanently readable; query files are static text.
# Pinned to the final commit before archival.
RUN <<EOF
set -e
git clone --filter=blob:none --sparse \
    https://github.com/nvim-treesitter/nvim-treesitter.git /tmp/nvim-ts
git -C /tmp/nvim-ts -c advice.detachedHead=false checkout 4916d6592ede8c07973490d9322f187e07dfefac
git -C /tmp/nvim-ts sparse-checkout set runtime/queries
# Verify sparse checkout populated the queries directory before copying.
[ -d /tmp/nvim-ts/runtime/queries/lua ] || { echo "ERROR: sparse checkout incomplete — queries/lua missing"; exit 1; }
mkdir -p /etc/xdg/nvim/queries
cp -r /tmp/nvim-ts/runtime/queries/. /etc/xdg/nvim/queries/
# Verify the copy succeeded — at least the lua queries must be present.
[ -d /etc/xdg/nvim/queries/lua ] || { echo "ERROR: query copy failed or incomplete"; exit 1; }
rm -rf /tmp/nvim-ts
EOF

# Generate a static Lua table mapping each installed tree-sitter parser to its
# shared-object path. Avoids runtime nm/dlsym discovery overhead.
# Re-run nvim-gen-treesitter-parsers inside the container after installing
# or removing tree-sitter-* packages.
RUN <<EOF
set -e
nvim-gen-treesitter-parsers
grep -q 'lang=' /etc/xdg/nvim/lua/treesitter_parsers.lua \
    || { echo "ERROR: treesitter_parsers.lua is empty — no parsers registered"; exit 1; }
EOF

# vim: set ft=dockerfile:
