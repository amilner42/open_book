// We import the CSS which is extracted to its own file by esbuild.
// Remove this line if you add a your own CSS build pipeline (e.g postcss).
import "../css/app.css"

import "./bulma_navbar"

// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix"
import { LiveSocket } from "phoenix_live_view"
import topbar from "../vendor/topbar"

var navbar;
var navbar_padding;

const hooks = {
    InnerBar: {
        mounted() {
            navbar = this.el;
        }
    },
    InnerBarPadding: {
        mounted() {
            navbar_padding = this.el;
        }
    }
}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, { params: { _csrf_token: csrfToken}, hooks: hooks })

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" })
window.addEventListener("phx:page-loading-start", info => topbar.show())
window.addEventListener("phx:page-loading-stop", info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

// Refer: https://css-tricks.com/the-trick-to-viewport-units-on-mobile/
// First we get the viewport height and we multiple it by 1% to get a value for a vh unit
let vh = window.innerHeight * 0.01;
// Then we set the value in the --vh custom property to the root of the document
document.documentElement.style.setProperty('--vh', `${vh}px`);

// Refer: https://fly.io/phoenix-files/copy-to-clipboard-with-phoenix-liveview/
window.addEventListener("phx:copy", (event) => {
    let text_to_copy = event.target.dataset.text_to_copy;
    navigator.clipboard.writeText(text_to_copy).then(() => {
        // copied.
    })
})

const sticky_height = 50;
window.onscroll = function() {stickInnerBarIfPresent()};
function stickInnerBarIfPresent() {
  if (window.pageYOffset >= sticky_height) {
    navbar.classList.add("sticky")
    navbar_padding.classList.remove("is-hidden")
  } else {
    navbar.classList.remove("sticky");
    navbar_padding.classList.add("is-hidden")
  }
}