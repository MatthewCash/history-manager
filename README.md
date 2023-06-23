# history-manager

Every 5 minutes history items over 1 month old will be removed unless the URL is still currently open in a tab

## Installation

### With Nix (Firefox only)

1. Run `nix build`
2. Load addon from `./result/addon/history-manager.zip`

### Manually

1. Install dependencies with `npm install`
2. Build for your browser with `npm run build:firefox` or `npm run build:chrome`
3. Pack into zip with `npm run pack`
4. Load addon from `./ext-out/history-manager.zip`
