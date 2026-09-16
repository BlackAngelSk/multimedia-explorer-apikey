Multimedia Explorer — macOS
==========================

Quick Start:
  1. Double-click MultimediaExplorer.app
  2. Wait a few seconds for the server to start
  3. Browser opens automatically to http://localhost:3000
  4. To quit: right-click the app in the Dock > Quit

First Run Notes:
  - macOS may show a "cannot be opened because the developer cannot be verified" warning.
    Go to: System Settings > Privacy & Security > click "Allow Anyway"
  - The server runs on port 3000 by default

Requirements:
  - macOS 11.0 (Big Sur) or later
  - Node.js is bundled — no separate installation needed

Configuration:
  - The .env file is included in the app bundle
  - To change API keys, edit the .env file inside the app:
    Right-click MultimediaExplorer.app > Show Package Contents >
    Contents > MacOS > .env
