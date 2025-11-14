SCRIPT_DIR=$(dirname "$0")
sudo apt upgrade
sudo apt install btop starship tmux fzf
ln -s "$SCRIPT_DIR/.tmux-utils.sh" "$HOME/.tmux-utils.sh"
ln -s "$SCRIPT_DIR/starship.toml" "$HOME/.config/starship.toml"
ln -s "$SCRIPT_DIR/.tmux.conf" "$HOME/.tmux.conf"
cp "$SCRIPT_DIR/.bashrc" "$HOME/.bashrc"
