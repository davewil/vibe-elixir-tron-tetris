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
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: {_csrf_token: csrfToken}
})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// Sound system for Tetris game
const SoundSystem = {
  sounds: {},
  initialized: false,
  enabled: true,
  
  init() {
    if (this.initialized) return
    
    // Define sounds with their URLs - adjust these paths as needed
    const soundConfig = {
      move: "/sounds/move.mp3",
      rotate: "/sounds/rotate.mp3",
      drop: "/sounds/drop.mp3",
      line_clear: "/sounds/line_clear.mp3",
      tetris: "/sounds/tetris.mp3",
      level_up: "/sounds/level_up.mp3",
      game_over: "/sounds/game_over.mp3"
    }
    
    // Preload sounds
    for (const [name, url] of Object.entries(soundConfig)) {
      const audio = new Audio(url)
      audio.preload = "auto"
      this.sounds[name] = audio
    }
    
    this.initialized = true
  },
  
  play(name) {
    if (!this.initialized) this.init()
    if (!this.enabled) return
    
    const sound = this.sounds[name]
    if (sound) {
      sound.currentTime = 0
      sound.play().catch(err => console.warn("Sound play failed:", err))
    }
  },
  
  setEnabled(enabled) {
    this.enabled = enabled
  }
}

// Initialize sound system on page load
document.addEventListener("DOMContentLoaded", () => {
  SoundSystem.init()
})

// Hook up sound event handling
window.addEventListener("phx:play_sound", (e) => {
  const { name } = e.detail
  SoundSystem.play(name)
})

// Handle sound toggle event
window.addEventListener("phx:toggle_sound", (e) => {
  const { enabled } = e.detail
  SoundSystem.setEnabled(enabled)
})

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

