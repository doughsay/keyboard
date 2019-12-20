// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from '../css/app.css'

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import 'phoenix_html'

// Import local files
//
// Local files can be imported directly using relative paths, for example:
// import socket from "./socket"

import { Socket } from 'phoenix'
import LiveSocket from 'phoenix_live_view'

const Hooks = {
  KeyDrag: {
    mounted () {
      this.el.addEventListener(
        'dragstart',
        function (ev) {
          ev.dataTransfer.setData('text/plain', ev.target.id)
        },
        false
      )
    }
  },

  KeyDrop: {
    mounted () {
      const context = this

      this.el.addEventListener(
        'dragover',
        function (ev) {
          ev.preventDefault()
        },
        false
      )

      this.el.addEventListener(
        'drop',
        function (ev) {
          ev.preventDefault()

          const keycode = ev.dataTransfer.getData('text/plain')
          const key = ev.target.id

          context.pushEvent('set_keycode', { key: key, keycode: keycode })
        },
        false
      )
    }
  }
}

let liveSocket = new LiveSocket('/live', Socket, { hooks: Hooks })

liveSocket.connect()
