rm -rf ~/Library/Application Support/Code - Insiders/User/settings.json
rm -rf ~/Library/Application Support/Code - Insiders/User/keybindings.json

ln -s ~/dotfiles/vscode/settings.json
ln -s ~/dotfiles/vscode/keybindings.json ~/Library/Application Support/Code - Insiders/User/keybindings.json
