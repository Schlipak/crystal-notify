# ![](https://cdn.rawgit.com/Schlipak/crystal-notify/7adf48651fbf8eeadc7bfdf8ad536f5ca7b4b90a/res/icon.svg) Crystal-Notify

[Crystal](https://crystal-lang.org/) bindings for [libnotify](https://developer.gnome.org/libnotify/)

This library is intended to be a complete binding of all functionalities available in libnotify.

For a more lightweight version, check out [libnotify.cr](https://github.com/splattael/libnotify.cr)

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  crystal-notify:
    github: schlipak/crystal-notify
```

Then run `crystal deps`

## Usage

```crystal
require "crystal-notify"

manager = Notify::Manager.new "MyApp"
manager.notify("Summary", "Body", "dialog-ok").show
```

[Documentation](https://schlipak.github.io/crystal-notify/)

## Contributing

1. [Fork it](https://github.com/schlipak/crystal-notify/fork)
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- Guillaume '[Schlipak](https://github.com/schlipak)' de Matos - creator, maintainer
