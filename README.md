<h1 align="center">vlc-dirty-sexual-skipper</h1>
<p align="center">Automatically skip dirty/sexual content in VLC.</p>
<p align="center"><a href="#readme"><img src="https://raw.githubusercontent.com/michaelbull/vlc-credit-skipper/master/preview.png" alt="Preview" /></a></p>

## Installation

Download the [`dirty-sexual-skipper.luac`](dirty-sexual-skipper.luac) file and place it in
your VLC extensions directory:

- Linux
    - `~/.local/share/vlc/lua/extensions/`
- Windows
    - `<Installation Folder>\vlc\lua\extensions\`
- macOS
    - `/Users/<name>/Library/Application Support/org.videolan.vlc/lua/extensions/`

## Usage

1. Open Movie
2. From the <kbd>View</kbd> menu, select <kbd>Dirty Sexual Skipper</kbd>.
3. If you have an existing profile, select it from the dropdown menu and press
   <kbd>Load</kbd>. This will populate the settings section with the values
   loaded from the selected profile.
4. The settings section can be used to configure an existing profile or to
   create a new one. Click the <kbd>Save</kbd> button to save your changes.
6. Profiles are saved as a file named `ds-skipper.conf` in your VLC [config
   directory][config-dir], alongside your `vlcrc` file.
7. Press the <kbd>Start Playlist</kbd> button to play the playlist with the skip
   settings applied.

https://luac.mtasa.com/

## Contributing

Bug reports and pull requests are welcome on [GitHub][github].

## License

This project is available under the terms of the ISC license. See the
[`LICENSE`](LICENSE) file for the copyright information and licensing terms.

[github]: https://github.com/mohamed-okasha/dirty-sexual-skipper.git
[config-dir]: https://www.videolan.org/support/faq.html#Config
