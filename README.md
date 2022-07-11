<!-- MDOC !-->
# ExFinder

**WARNING: This is a work in progress. Do not use it in production!!!**

ExFinder is a File Manager implemented with LiveView and designed to be easily
integrated with WYSIWYG editors for picking files.

ExFinder inside of a TinyMCE window for picking a file:
![screenshot](https://github.com/luisgabrielroldan/ex_finder/raw/main/screenshot.png)


## Installation

1. Add `ex_finder` to your dependencies in `mix.exs`. Then, run `mix deps.get`:
  
```elixir
def deps do
  [
    {:ex_finder, "~> 0.1.0"}
  ]
end
```

2. Create the session manager module:

```elixir
defmodule MyApp.SessionManager do
  def init(_session_data) do
    ExFinder.Adapters.Local.new(
      "/base/path/to/files",
      "http://example.com/mounted/files")
  end
end
```

3. Configure the session manager:

```elixir
config :ex_finder, :session_manager, MyApp.SessionManager
```

4. Add a call for mounting the assets in your `endpoint.ex`

```elixir
defmodule MyApp.Endpoint do
  use Phoenix.Endpoint, otp_app: :my_app

  import ExFinder.Router

  ...

  ex_finder_assets()
  
  ...
  
end
```

5. Add the route to your `router.ex`


```elixir
defmodule MyApp.Router do
  use Phoenix.Router

  import ExFinder.Router

  ...

  scope "/" do
    pipe_through(:browser)
    
    ex_finder("/ex_finder")
  end
end
```

## Configuring Editors

### CKEditor

CKEditor is detected automatically. You just need to add the `filebrowserBrowseUrl` 
to the configuration.

```javascript
CKEDITOR.replace('textarea', {
  filebrowserBrowseUrl: '/ex_finder',
});
```

### Other editors

Other editors can use the `callback` parameter when loading the browser.
The callback function will be called in the opener/parent window when
the file is selected.

Example using TinyMCE 4
```javascript
tinymce.init({
  selector: '#tinymce_input',
  menubar: false,
  plugins: [ "image", "link" ],
  image_advtab: true,
  file_browser_callback: function(field_name, url, type, win) {
    window.SetFileUrl = function(fileUrl) {
      console.log(fileUrl);
      document.getElementById(field_name).value = fileUrl;
      win.tinyMCE.activeEditor.windowManager.close();
    }

    tinymce.activeEditor.windowManager.open({
      title: 'Browse Image',
      file: "/ex_finder?callback=SetFileUrl&type=" + type,
      width: 800,
      height: 500,
      buttons: [{
        text: 'Close',
        onclick: 'close',
        window : win,
        input : field_name
      }]
    });

    return false;
  },
});

```

<!-- MDOC !-->

## Contributing

For runing a dev version of the project you can use the following command:

```
$ mix setup
$ mix dev
```

Assets are minimized by default. For skipping the assets optimization you can use
the `NODE_ENV` environment variable:

```
$ NODE_ENV=development mix dev
```

The mounted path can be changed with the `FIXTURES` environment variable:

```
$ FIXTURES=/any/folder mix dev
```

## License

MIT License. Copyright (c) 2022 Gabriel Roldán
