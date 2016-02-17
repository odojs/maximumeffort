seuss = require 'seuss-queue'

module.exports = (url, maxWorkers) ->
  maxWorkers ?= 16
  count = 0
  available = seuss()
  pending = seuss()
  busy = {}

  create = (id) ->
    internal = new Worker url
    internal.addEventListener 'message', (e) ->
      worker = busy[id]
      delete busy[id]
      available.enqueue worker
      cb = worker.callback
      cb null, e.data
      drain()
    id: id
    internal: internal

  drain = ->
    return if pending.length() is 0
    task = pending.dequeue()
    emit task.event, task.payload, task.callback

  stop = (events) ->
    for id, worker of busy
      if worker.event in events
        delete busy[id]
        worker.internal.terminate()
        available.enqueue create id
    tocheck = pending
    pending = seuss()
    while tocheck.length > 0
      task = tocheck.dequeue()
      continue if task.event in events
      pending.enqueue task

  emit = (e, p, cb) ->
    if available.length() > 0
      worker = available.dequeue()
      busy[worker.id] = worker
      worker.event = e
      worker.payload = p
      worker.callback = cb
      worker.internal.postMessage
        id: worker.id
        event: e
        payload: p
      return

    if count < maxWorkers
      count++
      available.enqueue create count
      return emit e, p, cb

    pending.enqueue
      event: e
      payload: p
      callback: cb

  emit: emit
  stop: stop
  info: ->
    available: available.length()
    pending: pending.length()
    busy: Object.keys(busy).length
