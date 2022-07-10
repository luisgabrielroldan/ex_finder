Logger.configure(level: :debug)

Application.put_env(:ex_finder, :session_manager, DemoWeb.SessionManager)

Application.put_env(:ex_finder, DemoWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "Hu4qQN3iKzTV4fJxhorPQlA/osH9fAMtbtjVS58PFgfw3ja5Z18Q/WSNR9wP4OfW",
  live_view: [signing_salt: "hMegieSe"],
  http: [port: System.get_env("PORT") || 4000],
  debug_errors: true,
  check_origin: false,
  pubsub_server: Demo.PubSub,
  watchers: [
    node: [
      "build.js",
      cd: Path.expand("assets/scripts/", __DIR__),
      env: %{
        "ESBUILD_LOG_LEVEL" => "silent",
        "ESBUILD_WATCH" => "1",
        "NODE_ENV" => System.get_env("NODE_ENV") || "production"
      }
    ]
  ],
  live_reload: [
    patterns: [
      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"lib/ex_finder/web/.*(ex)$",
    ]
  ]
)

defmodule DemoWeb.SessionManager do
  def init(_live_session) do
    ExFinder.Adapters.Local.new(System.get_env("FIXTURES", "./fixtures"), "http://localhost:4000/files")
  end
end

defmodule DemoWeb.PageController do
  import Plug.Conn

  @html """
  <!DOCTYPE html>
  <html>
  <head>
  <script src="https://cdn.ckeditor.com/4.19.0/standard/ckeditor.js"></script>
  <script src="https://cdn.tiny.cloud/1/no-api-key/tinymce/4/tinymce.min.js"></script>
  </head>

  <body>
    <h1>CK Editor</h1>
    <textarea name="ck_editor"></textarea>

    <h1>TinyMCE 4</h1>
    <textarea id="tinymce_editor">
    </textarea>

    <script>
      CKEDITOR.replace('ck_editor', {
        filebrowserBrowseUrl: '/ex_finder',
      });

      tinymce.init({
        selector: '#tinymce_editor',
        height: 300,
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
    </script>
  </body>
  </html>
  """

  def init(opts), do: opts

  def call(conn, _opt) do
    conn
    |> put_resp_header("content-type", "text/html")
    |> send_resp(200, @html)
  end
end

defmodule DemoWeb.Router do
  use Phoenix.Router

  import ExFinder.Router

  pipeline :browser do
    plug(:fetch_session)
  end

  scope "/" do
    pipe_through(:browser)
    get("/", DemoWeb.PageController, :index)
    ex_finder("/ex_finder")
  end
end

defmodule DemoWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :ex_finder

  import ExFinder.Router

  socket("/live", Phoenix.LiveView.Socket)
  socket("/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket)

  plug(Phoenix.LiveReloader)
  plug(Phoenix.CodeReloader)

  plug(Plug.Session,
    store: :cookie,
    key: "_ex_finder_key",
    signing_salt: "/MySiGnG1nGS4lt"
  )

  plug(Plug.RequestId)

  plug Plug.Static,
    at: "/files", from: System.get_env("FIXTURES", "./fixtures")

  ex_finder_assets()

  plug(DemoWeb.Router)
end

Application.put_env(:phoenix, :serve_endpoints, true)

Task.async(fn ->
  children = [
    {Phoenix.PubSub, [name: Demo.PubSub, adapter: Phoenix.PubSub.PG2]},
    DemoWeb.Endpoint
  ]

  {:ok, _} = Supervisor.start_link(children, strategy: :one_for_one)
  Process.sleep(:infinity)
end)
|> Task.await(:infinity)
