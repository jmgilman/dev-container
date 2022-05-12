# dev-container

Source files for my personal development container.

Example config:

```json
{
    "build": {
        "dockerfile": "Dockerfile"
    },
    "mounts": [
        "source=jmgilman-dev,target=/nix,type=volume",
        "source=jmgilman-dev-ext,target=/home/vscode/.vscode-server/extensions,type=volume",
        "source=jmgilman-dev-extin,target=/home/vscode/.vscode-server-insiders/extensions,type=volume",
    ],
    "remoteUser": "vscode",
    "settings": {
        "terminal.integrated.defaultProfile.linux": "zsh",
        "terminal.integrated.profiles.linux": {
            "zsh": {
                "path": "/home/vscode/.nix-profile/bin/zsh"
            },
        }
    }
}
```
