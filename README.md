# Crystal-Notify <img src="./res/icon.svg">

[Crystal](https://crystal-lang.org/) bindings for [libnotify](https://developer.gnome.org/libnotify/)

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

manager = Notify::Manager.new("MyApp")
manager.notify("Summary", "Body", "dialog-ok").show
```

[Documentation](https://schlipak.github.io/crystal-notify/)


## Contributing

1. Fork it ( https://github.com/schlipak/crystal-notify/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- Guillaume '[Schlipak](https://github.com/schlipak)' de Matos - creator, maintainer
