AtomJstipsView = require './atom-jstips-view'
{CompositeDisposable} = require 'atom'
request = require 'request'
moment = require 'moment'
marked = require 'marked'

marked.setOptions({
  highlight: (code) ->
    require('highlight.js').highlightAuto(code).value
})

module.exports = AtomJstips =
  atomJstipsView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @atomJstipsView = new AtomJstipsView(state.atomJstipsViewState)
    @modalPanel = atom.workspace.addRightPanel(item: @atomJstipsView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'atom-jstips:toggle': => @toggle()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @atomJstipsView.destroy()

  serialize: ->
    atomJstipsViewState: @atomJstipsView.serialize()

  toggle: ->
    console.log 'AtomJstips was toggled!'

    if @modalPanel.isVisible()
      @modalPanel.hide()
    else
      @getTip((t) => @atomJstipsView.setTodaysTip(marked(t)))
      @modalPanel.show()

  getTip: (callback) ->
    rx = /(## #[\s\S]+?(?=## #\d))/g
    rxd = /(?:> )([-\d]+)/g
    request.get 'https://raw.githubusercontent.com/loverajoel/jstips/master/README.md', (e, r, b) =>
      foo = rx.exec(b)
      tips = b.match(rx)
      parse = (t) ->
        date = moment(rxd.exec(t.match(rxd))[1])
        body = t

        return {date: date, body: body}

      tipList = (parse tip for tip in tips)
      # console.log(marked(tipList.pop().body))
      callback(marked(tipList.pop().body))
