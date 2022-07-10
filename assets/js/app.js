import '../css/app.scss';

import "phoenix_html"
import { LiveSocket } from "phoenix_live_view"
import { Socket, LongPoll } from "phoenix"
import Hooks from "./hooks"
import { getUrlParam } from "./utils"

let socketPath = document.querySelector("html").getAttribute("phx-socket") || "/live"
let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")

let liveSocket = new LiveSocket(socketPath, Socket, {
  hooks: Hooks,
  params: (liveViewName) => {
    return {
      _csrf_token: csrfToken
    };
  },
})

window.addEventListener('phx:file_selected', (e) => {
  var fileUrl = e.detail.url;
  var ckEditorFuncNum = getUrlParam('CKEditorFuncNum');
  var callback = getUrlParam('callback');

  if (callback) {
      var win = (window.opener ? window.opener : window.parent);
      win[callback](fileUrl);
  } else if (ckEditorFuncNum) {
    window.opener.CKEDITOR.tools.callFunction(ckEditorFuncNum, fileUrl);
    window.close();
  } else {
    console.log("Unknown callback function");
  }
})

liveSocket.enableDebug();
liveSocket.connect();
window.liveSocket = liveSocket;
