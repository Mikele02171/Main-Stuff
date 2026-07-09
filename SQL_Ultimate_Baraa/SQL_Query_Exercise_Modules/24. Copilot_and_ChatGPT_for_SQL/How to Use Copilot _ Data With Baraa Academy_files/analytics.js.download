!(function umd(require) {
  'object' == typeof exports
    ? (module.exports = require('1'))
    : 'function' == typeof define && (define.amd || define.cmd)
    ? define(function () {
        return require('1')
      })
    : (this.fedoraAnalytics = require('1'))
})(
  (function outer(modules, cache, entries) {
    var global = (function () {
      return this
    })()
    function require(name, jumped) {
      if (cache[name]) return cache[name].exports
      if (modules[name]) return call(name, require)
      throw new Error('cannot find module "' + name + '"')
    }
    function call(id, require) {
      var m = { exports: {} },
        mod = modules[id],
        name = mod[2],
        fn
      return (
        mod[0].call(
          m.exports,
          function (req) {
            var dep = modules[id][1][req]
            return require(dep || req)
          },
          m,
          m.exports,
          outer,
          modules,
          cache,
          entries
        ),
        (cache[id] = m),
        name && (cache[name] = cache[id]),
        cache[id].exports
      )
    }
    for (var id in entries)
      entries[id] ? (global[entries[id]] = require(id)) : require(id)
    return (
      (require.duo = !0),
      (require.cache = cache),
      (require.modules = modules),
      require
    )
  })(
    {
      1: [
        function (require, module, exports) {
          var Analytics = require('./analytics'),
            Integrations = require('./integrations'),
            each = require('each'),
            fedoraAnalytics = (module.exports = exports = new Analytics())
          ;(fedoraAnalytics.require = require),
            each(Integrations, function (name, Integration) {
              fedoraAnalytics.use(Integration)
            })
        },
        { './analytics': 2, './integrations': 3, each: 4 },
      ],
      2: [
        function (require, module, exports) {
          var _analytics = window.fedoraAnalytics,
            Emitter = require('emitter'),
            Facade = require('facade'),
            after = require('after'),
            bind = require('bind'),
            callback = require('callback'),
            clone = require('clone'),
            cookie = require('./cookie'),
            debug = require('debug'),
            defaults = require('defaults'),
            each = require('each'),
            group = require('./group'),
            is = require('is'),
            isMeta = require('is-meta'),
            keys = require('object').keys,
            memory = require('./memory'),
            normalize = require('./normalize'),
            on = require('event').bind,
            pageDefaults = require('./pageDefaults'),
            pick = require('pick'),
            prevent = require('prevent'),
            querystring = require('querystring'),
            size = require('object').length,
            store = require('./store'),
            user = require('./user'),
            Alias = Facade.Alias,
            Group = Facade.Group,
            Identify = Facade.Identify,
            Page = Facade.Page,
            Track = Facade.Track
          function Analytics() {
            this._options({}),
              (this.Integrations = {}),
              (this._integrations = {}),
              (this._readied = !1),
              (this._timeout = 300),
              (this._user = user),
              (this.log = debug('analytics.js')),
              bind.all(this)
            var self = this
            this.on('initialize', function (settings, options) {
              options.initialPageview && self.page(), self._parseQuery()
            })
          }
          ;((exports = module.exports = Analytics).cookie = cookie),
            (exports.store = store),
            (exports.memory = memory),
            Emitter(Analytics.prototype),
            (Analytics.prototype.use = function (plugin) {
              return plugin(this), this
            }),
            (Analytics.prototype.addIntegration = function (Integration) {
              var name = Integration.prototype.name
              if (!name)
                throw new TypeError('attempted to add an invalid integration')
              return (this.Integrations[name] = Integration), this
            }),
            (Analytics.prototype.init = Analytics.prototype.initialize =
              function (settings, options) {
                ;(settings = settings || {}),
                  (options = options || {}),
                  this._options(options),
                  (this._readied = !1)
                var self = this
                each(settings, function (name) {
                  var Integration
                  self.Integrations[name] || delete settings[name]
                }),
                  each(settings, function (name, opts) {
                    var Integration,
                      integration = new (0, self.Integrations[name])(
                        clone(opts)
                      )
                    self.log('initialize %o - %o', name, opts),
                      self.add(integration)
                  })
                var integrations = this._integrations
                user.load(), group.load()
                var ready = after(size(integrations), function () {
                  ;(self._readied = !0), self.emit('ready')
                })
                return (
                  each(integrations, function (name, integration) {
                    options.initialPageview &&
                      !1 === integration.options.initialPageview &&
                      (integration.page = after(2, integration.page)),
                      (integration.analytics = self),
                      integration.once('ready', ready),
                      integration.initialize()
                  }),
                  (this.initialized = !0),
                  this.emit('initialize', settings, options),
                  this
                )
              }),
            (Analytics.prototype.setAnonymousId = function (id) {
              return this.user().anonymousId(id), this
            }),
            (Analytics.prototype.add = function (integration) {
              return (this._integrations[integration.name] = integration), this
            }),
            (Analytics.prototype.identify = function (id, traits, options, fn) {
              is.fn(options) && ((fn = options), (options = null)),
                is.fn(traits) &&
                  ((fn = traits), (options = null), (traits = null)),
                is.object(id) &&
                  ((options = traits), (traits = id), (id = user.id())),
                user.identify(id, traits)
              var msg = this.normalize({
                options: options,
                traits: user.traits(),
                userId: user.id(),
              })
              return (
                this._invoke('identify', new Identify(msg)),
                this.emit('identify', id, traits, options),
                this._callback(fn),
                this
              )
            }),
            (Analytics.prototype.user = function () {
              return user
            }),
            (Analytics.prototype.group = function (id, traits, options, fn) {
              if (!arguments.length) return group
              is.fn(options) && ((fn = options), (options = null)),
                is.fn(traits) &&
                  ((fn = traits), (options = null), (traits = null)),
                is.object(id) &&
                  ((options = traits), (traits = id), (id = group.id())),
                group.identify(id, traits)
              var msg = this.normalize({
                options: options,
                traits: group.traits(),
                groupId: group.id(),
              })
              return (
                this._invoke('group', new Group(msg)),
                this.emit('group', id, traits, options),
                this._callback(fn),
                this
              )
            }),
            (Analytics.prototype.track = function (
              event,
              properties,
              options,
              fn
            ) {
              is.fn(options) && ((fn = options), (options = null)),
                is.fn(properties) &&
                  ((fn = properties), (options = null), (properties = null))
              var plan = this.options.plan || {},
                events = plan.track || {},
                msg = this.normalize({
                  properties: properties,
                  options: options,
                  event: event,
                })
              if ((plan = events[event])) {
                if (
                  (this.log('plan %o - %o', event, plan), !1 === plan.enabled)
                )
                  return this._callback(fn)
                defaults(msg.integrations, plan.integrations || {})
              }
              return (
                this._invoke('track', new Track(msg)),
                this.emit('track', event, properties, options),
                this._callback(fn),
                this
              )
            }),
            (Analytics.prototype.trackClick = Analytics.prototype.trackLink =
              function (links, event, properties) {
                if (!links) return this
                is.element(links) && (links = [links])
                var self = this
                return (
                  each(links, function (el) {
                    if (!is.element(el))
                      throw new TypeError(
                        'Must pass HTMLElement to `analytics.trackLink`.'
                      )
                    on(el, 'click', function (e) {
                      var ev = is.fn(event) ? event(el) : event,
                        props = is.fn(properties) ? properties(el) : properties,
                        href =
                          el.getAttribute('href') ||
                          el.getAttributeNS(
                            'http://www.w3.org/1999/xlink',
                            'href'
                          ) ||
                          el.getAttribute('xlink:href')
                      self.track(ev, props),
                        href &&
                          '_blank' !== el.target &&
                          !isMeta(e) &&
                          (prevent(e),
                          self._callback(function () {
                            window.location.href = href
                          }))
                    })
                  }),
                  this
                )
              }),
            (Analytics.prototype.trackSubmit = Analytics.prototype.trackForm =
              function (forms, event, properties) {
                if (!forms) return this
                is.element(forms) && (forms = [forms])
                var self = this
                return (
                  each(forms, function (el) {
                    if (!is.element(el))
                      throw new TypeError(
                        'Must pass HTMLElement to `analytics.trackForm`.'
                      )
                    function handler(e) {
                      prevent(e)
                      var ev = is.fn(event) ? event(el) : event,
                        props = is.fn(properties) ? properties(el) : properties
                      self.track(ev, props),
                        self._callback(function () {
                          el.submit()
                        })
                    }
                    var $ = window.jQuery || window.Zepto
                    $ ? $(el).submit(handler) : on(el, 'submit', handler)
                  }),
                  this
                )
              }),
            (Analytics.prototype.page = function (
              category,
              name,
              properties,
              options,
              fn
            ) {
              is.fn(options) && ((fn = options), (options = null)),
                is.fn(properties) &&
                  ((fn = properties), (options = properties = null)),
                is.fn(name) &&
                  ((fn = name), (options = properties = name = null)),
                is.object(category) &&
                  ((options = name),
                  (properties = category),
                  (name = category = null)),
                is.object(name) &&
                  ((options = properties), (properties = name), (name = null)),
                is.string(category) &&
                  !is.string(name) &&
                  ((name = category), (category = null)),
                (properties = clone(properties) || {}),
                name && (properties.name = name),
                category && (properties.category = category)
              var defs = pageDefaults()
              defaults(properties, defs)
              var overrides = pick(keys(defs), properties)
              is.empty(overrides) ||
                (((options = options || {}).context = options.context || {}),
                (options.context.page = overrides))
              var msg = this.normalize({
                properties: properties,
                category: category,
                options: options,
                name: name,
              })
              return (
                this._invoke('page', new Page(msg)),
                this.emit('page', category, name, properties, options),
                this._callback(fn),
                this
              )
            }),
            (Analytics.prototype.pageview = function (url) {
              var properties = {}
              return url && (properties.path = url), this.page(properties), this
            }),
            (Analytics.prototype.alias = function (to, from, options, fn) {
              is.fn(options) && ((fn = options), (options = null)),
                is.fn(from) && ((fn = from), (options = null), (from = null)),
                is.object(from) && ((options = from), (from = null))
              var msg = this.normalize({
                options: options,
                previousId: from,
                userId: to,
              })
              return (
                this._invoke('alias', new Alias(msg)),
                this.emit('alias', to, from, options),
                this._callback(fn),
                this
              )
            }),
            (Analytics.prototype.ready = function (fn) {
              return (
                is.fn(fn) &&
                  (this._readied ? callback.async(fn) : this.once('ready', fn)),
                this
              )
            }),
            (Analytics.prototype.timeout = function (timeout) {
              this._timeout = timeout
            }),
            (Analytics.prototype.debug = function (str) {
              !arguments.length || str
                ? debug.enable('analytics:' + (str || '*'))
                : debug.disable()
            }),
            (Analytics.prototype._options = function (options) {
              return (
                (options = options || {}),
                (this.options = options),
                cookie.options(options.cookie),
                store.options(options.localStorage),
                user.options(options.user),
                group.options(options.group),
                this
              )
            }),
            (Analytics.prototype._callback = function (fn) {
              return callback.async(fn, this._timeout), this
            }),
            (Analytics.prototype._invoke = function (method, facade) {
              return (
                this.emit('invoke', facade),
                each(this._integrations, function (name, integration) {
                  facade.enabled(name) &&
                    integration.invoke.call(integration, method, facade)
                }),
                this
              )
            }),
            (Analytics.prototype.push = function (args) {
              var method = args.shift()
              this[method] && this[method].apply(this, args)
            }),
            (Analytics.prototype.reset = function () {
              this.user().logout(), this.group().logout()
            }),
            (Analytics.prototype._parseQuery = function () {
              var q = querystring.parse(window.location.search)
              return (
                q.ajs_uid && this.identify(q.ajs_uid),
                q.ajs_event && this.track(q.ajs_event),
                q.ajs_aid && user.anonymousId(q.ajs_aid),
                this
              )
            }),
            (Analytics.prototype.normalize = function (msg) {
              return (
                (msg = normalize(msg, keys(this._integrations))).anonymousId &&
                  user.anonymousId(msg.anonymousId),
                (msg.anonymousId = user.anonymousId()),
                (msg.context.page = defaults(
                  msg.context.page || {},
                  pageDefaults()
                )),
                msg
              )
            }),
            (Analytics.prototype.noConflict = function () {
              return (window.analytics = _analytics), this
            })
        },
        {
          emitter: 6,
          facade: 7,
          after: 8,
          bind: 9,
          callback: 10,
          clone: 11,
          './cookie': 12,
          debug: 13,
          defaults: 14,
          each: 4,
          './group': 15,
          is: 16,
          'is-meta': 17,
          object: 18,
          './memory': 19,
          './normalize': 20,
          event: 21,
          './pageDefaults': 22,
          pick: 23,
          prevent: 24,
          querystring: 25,
          './store': 26,
          './user': 27,
        },
      ],
      6: [
        function (require, module, exports) {
          var index = require('indexof')
          function Emitter(obj) {
            if (obj) return mixin(obj)
          }
          function mixin(obj) {
            for (var key in Emitter.prototype) obj[key] = Emitter.prototype[key]
            return obj
          }
          ;(module.exports = Emitter),
            (Emitter.prototype.on = Emitter.prototype.addEventListener =
              function (event, fn) {
                return (
                  (this._callbacks = this._callbacks || {}),
                  (this._callbacks[event] = this._callbacks[event] || []).push(
                    fn
                  ),
                  this
                )
              }),
            (Emitter.prototype.once = function (event, fn) {
              var self = this
              function on() {
                self.off(event, on), fn.apply(this, arguments)
              }
              return (
                (this._callbacks = this._callbacks || {}),
                (fn._off = on),
                this.on(event, on),
                this
              )
            }),
            (Emitter.prototype.off =
              Emitter.prototype.removeListener =
              Emitter.prototype.removeAllListeners =
              Emitter.prototype.removeEventListener =
                function (event, fn) {
                  if (
                    ((this._callbacks = this._callbacks || {}),
                    0 == arguments.length)
                  )
                    return (this._callbacks = {}), this
                  var callbacks = this._callbacks[event]
                  if (!callbacks) return this
                  if (1 == arguments.length)
                    return delete this._callbacks[event], this
                  var i = index(callbacks, fn._off || fn)
                  return ~i && callbacks.splice(i, 1), this
                }),
            (Emitter.prototype.emit = function (event) {
              this._callbacks = this._callbacks || {}
              var args = [].slice.call(arguments, 1),
                callbacks = this._callbacks[event]
              if (callbacks)
                for (
                  var i = 0, len = (callbacks = callbacks.slice(0)).length;
                  i < len;
                  ++i
                )
                  callbacks[i].apply(this, args)
              return this
            }),
            (Emitter.prototype.listeners = function (event) {
              return (
                (this._callbacks = this._callbacks || {}),
                this._callbacks[event] || []
              )
            }),
            (Emitter.prototype.hasListeners = function (event) {
              return !!this.listeners(event).length
            })
        },
        { indexof: 28 },
      ],
      28: [
        function (require, module, exports) {
          module.exports = function (arr, obj) {
            if (arr.indexOf) return arr.indexOf(obj)
            for (var i = 0; i < arr.length; ++i) if (arr[i] === obj) return i
            return -1
          }
        },
        {},
      ],
      7: [
        function (require, module, exports) {
          var Facade = require('./facade')
          ;(module.exports = Facade),
            (Facade.Alias = require('./alias')),
            (Facade.Group = require('./group')),
            (Facade.Identify = require('./identify')),
            (Facade.Track = require('./track')),
            (Facade.Page = require('./page')),
            (Facade.Screen = require('./screen'))
        },
        {
          './facade': 29,
          './alias': 30,
          './group': 31,
          './identify': 32,
          './track': 33,
          './page': 34,
          './screen': 35,
        },
      ],
      29: [
        function (require, module, exports) {
          var clone = require('./utils').clone,
            type = require('./utils').type,
            isEnabled = require('./is-enabled'),
            objCase = require('obj-case'),
            traverse = require('isodate-traverse'),
            newDate = require('new-date')
          function Facade(obj) {
            obj.hasOwnProperty('timestamp')
              ? (obj.timestamp = newDate(obj.timestamp))
              : (obj.timestamp = new Date()),
              traverse(obj),
              (this.obj = obj)
          }
          function transform(obj) {
            var cloned
            return clone(obj)
          }
          ;(module.exports = Facade),
            (Facade.prototype.proxy = function (field) {
              var fields = field.split('.'),
                obj = this[(field = fields.shift())] || this.field(field)
              return obj
                ? ('function' == typeof obj && (obj = obj.call(this) || {}),
                  0 === fields.length
                    ? transform(obj)
                    : transform((obj = objCase(obj, fields.join('.')))))
                : obj
            }),
            (Facade.prototype.field = function (field) {
              var obj
              return transform(this.obj[field])
            }),
            (Facade.proxy = function (field) {
              return function () {
                return this.proxy(field)
              }
            }),
            (Facade.field = function (field) {
              return function () {
                return this.field(field)
              }
            }),
            (Facade.multi = function (path) {
              return function () {
                var multi = this.proxy(path + 's')
                if ('array' == type(multi)) return multi
                var one = this.proxy(path)
                return one && (one = [clone(one)]), one || []
              }
            }),
            (Facade.one = function (path) {
              return function () {
                var one = this.proxy(path)
                if (one) return one
                var multi = this.proxy(path + 's')
                return 'array' == type(multi) ? multi[0] : void 0
              }
            }),
            (Facade.prototype.json = function () {
              var ret = clone(this.obj)
              return this.type && (ret.type = this.type()), ret
            }),
            (Facade.prototype.context = Facade.prototype.options =
              function (integration) {
                var options = clone(this.obj.options || this.obj.context) || {}
                if (!integration) return clone(options)
                if (this.enabled(integration)) {
                  var integrations = this.integrations(),
                    value =
                      integrations[integration] ||
                      objCase(integrations, integration)
                  return 'boolean' == typeof value && (value = {}), value || {}
                }
              }),
            (Facade.prototype.enabled = function (integration) {
              var allEnabled = this.proxy('options.providers.all')
              'boolean' != typeof allEnabled &&
                (allEnabled = this.proxy('options.all')),
                'boolean' != typeof allEnabled &&
                  (allEnabled = this.proxy('integrations.all')),
                'boolean' != typeof allEnabled && (allEnabled = !0)
              var enabled = allEnabled && isEnabled(integration),
                options = this.integrations()
              if (
                (options.providers &&
                  options.providers.hasOwnProperty(integration) &&
                  (enabled = options.providers[integration]),
                options.hasOwnProperty(integration))
              ) {
                var settings = options[integration]
                enabled = 'boolean' != typeof settings || settings
              }
              return !!enabled
            }),
            (Facade.prototype.integrations = function () {
              return (
                this.obj.integrations ||
                this.proxy('options.providers') ||
                this.options()
              )
            }),
            (Facade.prototype.active = function () {
              var active = this.proxy('options.active')
              return null == active && (active = !0), active
            }),
            (Facade.prototype.sessionId = Facade.prototype.anonymousId =
              function () {
                return this.field('anonymousId') || this.field('sessionId')
              }),
            (Facade.prototype.groupId = Facade.proxy('options.groupId')),
            (Facade.prototype.traits = function (aliases) {
              var ret = this.proxy('options.traits') || {},
                id = this.userId()
              for (var alias in ((aliases = aliases || {}),
              id && (ret.id = id),
              aliases)) {
                var value =
                  null == this[alias]
                    ? this.proxy('options.traits.' + alias)
                    : this[alias]()
                null != value &&
                  ((ret[aliases[alias]] = value), delete ret[alias])
              }
              return ret
            }),
            (Facade.prototype.library = function () {
              var library = this.proxy('options.library')
              return library
                ? 'string' == typeof library
                  ? { name: library, version: null }
                  : library
                : { name: 'unknown', version: null }
            }),
            (Facade.prototype.userId = Facade.field('userId')),
            (Facade.prototype.channel = Facade.field('channel')),
            (Facade.prototype.timestamp = Facade.field('timestamp')),
            (Facade.prototype.userAgent = Facade.proxy('options.userAgent')),
            (Facade.prototype.ip = Facade.proxy('options.ip'))
        },
        {
          './utils': 36,
          './is-enabled': 37,
          'obj-case': 38,
          'isodate-traverse': 39,
          'new-date': 40,
        },
      ],
      36: [
        function (require, module, exports) {
          try {
            ;(exports.inherit = require('inherit')),
              (exports.clone = require('clone')),
              (exports.type = require('type'))
          } catch (e) {
            ;(exports.inherit = require('inherit-component')),
              (exports.clone = require('clone-component')),
              (exports.type = require('type-component'))
          }
        },
        { inherit: 41, clone: 42, type: 43 },
      ],
      41: [
        function (require, module, exports) {
          module.exports = function (a, b) {
            var fn = function () {}
            ;(fn.prototype = b.prototype),
              (a.prototype = new fn()),
              (a.prototype.constructor = a)
          }
        },
        {},
      ],
      42: [
        function (require, module, exports) {
          var type
          try {
            type = require('component-type')
          } catch (_) {
            type = require('type')
          }
          function clone(obj) {
            switch (type(obj)) {
              case 'object':
                var copy = {}
                for (var key in obj)
                  obj.hasOwnProperty(key) && (copy[key] = clone(obj[key]))
                return copy
              case 'array':
                for (
                  var copy = new Array(obj.length), i = 0, l = obj.length;
                  i < l;
                  i++
                )
                  copy[i] = clone(obj[i])
                return copy
              case 'regexp':
                var flags = ''
                return (
                  (flags += obj.multiline ? 'm' : ''),
                  (flags += obj.global ? 'g' : ''),
                  (flags += obj.ignoreCase ? 'i' : ''),
                  new RegExp(obj.source, flags)
                )
              case 'date':
                return new Date(obj.getTime())
              default:
                return obj
            }
          }
          module.exports = clone
        },
        { 'component-type': 43, type: 43 },
      ],
      43: [
        function (require, module, exports) {
          var toString = Object.prototype.toString
          module.exports = function (val) {
            switch (toString.call(val)) {
              case '[object Date]':
                return 'date'
              case '[object RegExp]':
                return 'regexp'
              case '[object Arguments]':
                return 'arguments'
              case '[object Array]':
                return 'array'
              case '[object Error]':
                return 'error'
            }
            return null === val
              ? 'null'
              : void 0 === val
              ? 'undefined'
              : val != val
              ? 'nan'
              : val && 1 === val.nodeType
              ? 'element'
              : typeof (val = val.valueOf
                  ? val.valueOf()
                  : Object.prototype.valueOf.apply(val))
          }
        },
        {},
      ],
      37: [
        function (require, module, exports) {
          var disabled = { Salesforce: !0 }
          module.exports = function (integration) {
            return !disabled[integration]
          }
        },
        {},
      ],
      38: [
        function (require, module, exports) {
          var identity = function (_) {
            return _
          }
          function multiple(fn) {
            return function (obj, path, val, options) {
              var normalize =
                  options && isFunction(options.normalizer)
                    ? options.normalizer
                    : defaultNormalize,
                key
              path = normalize(path)
              for (var finished = !1; !finished; ) loop()
              function loop() {
                for (key in obj) {
                  var normalizedKey = normalize(key)
                  if (0 === path.indexOf(normalizedKey)) {
                    var temp = path.substr(normalizedKey.length)
                    if ('.' === temp.charAt(0) || 0 === temp.length) {
                      path = temp.substr(1)
                      var child = obj[key]
                      return null == child
                        ? void (finished = !0)
                        : path.length
                        ? void (obj = child)
                        : void (finished = !0)
                    }
                  }
                }
                ;(key = void 0), (finished = !0)
              }
              if (key) return null == obj ? obj : fn(obj, key, val)
            }
          }
          function find(obj, key) {
            if (obj.hasOwnProperty(key)) return obj[key]
          }
          function del(obj, key) {
            return obj.hasOwnProperty(key) && delete obj[key], obj
          }
          function replace(obj, key, val) {
            return obj.hasOwnProperty(key) && (obj[key] = val), obj
          }
          function defaultNormalize(path) {
            return path.replace(/[^a-zA-Z0-9\.]+/g, '').toLowerCase()
          }
          function isFunction(val) {
            return 'function' == typeof val
          }
          ;(module.exports = multiple(find)),
            (module.exports.find = module.exports),
            (module.exports.replace = function (obj, key, val, options) {
              return multiple(replace).call(this, obj, key, val, options), obj
            }),
            (module.exports.del = function (obj, key, options) {
              return multiple(del).call(this, obj, key, null, options), obj
            })
        },
        {},
      ],
      39: [
        function (require, module, exports) {
          var is = require('is'),
            isodate = require('isodate'),
            each
          try {
            each = require('each')
          } catch (err) {
            each = require('each-component')
          }
          function traverse(input, strict) {
            return (
              void 0 === strict && (strict = !0),
              is.object(input)
                ? object(input, strict)
                : is.array(input)
                ? array(input, strict)
                : input
            )
          }
          function object(obj, strict) {
            return (
              each(obj, function (key, val) {
                isodate.is(val, strict)
                  ? (obj[key] = isodate.parse(val))
                  : (is.object(val) || is.array(val)) && traverse(val, strict)
              }),
              obj
            )
          }
          function array(arr, strict) {
            return (
              each(arr, function (val, x) {
                is.object(val)
                  ? traverse(val, strict)
                  : isodate.is(val, strict) && (arr[x] = isodate.parse(val))
              }),
              arr
            )
          }
          module.exports = traverse
        },
        { is: 44, isodate: 45, each: 4 },
      ],
      44: [
        function (require, module, exports) {
          var isEmpty = require('is-empty')
          try {
            var typeOf = require('type')
          } catch (e) {
            var typeOf = require('component-type')
          }
          for (
            var types = [
                'arguments',
                'array',
                'boolean',
                'date',
                'element',
                'function',
                'null',
                'number',
                'object',
                'regexp',
                'string',
                'undefined',
              ],
              i = 0,
              type;
            (type = types[i]);
            i++
          )
            exports[type] = generate(type)
          function generate(type) {
            return function (value) {
              return type === typeOf(value)
            }
          }
          ;(exports.fn = exports.function),
            (exports.empty = isEmpty),
            (exports.nan = function (val) {
              return exports.number(val) && val != val
            })
        },
        { 'is-empty': 46, type: 43, 'component-type': 43 },
      ],
      46: [
        function (require, module, exports) {
          module.exports = isEmpty
          var has = Object.prototype.hasOwnProperty
          function isEmpty(val) {
            if (null == val) return !0
            if ('number' == typeof val) return 0 === val
            if (void 0 !== val.length) return 0 === val.length
            for (var key in val) if (has.call(val, key)) return !1
            return !0
          }
        },
        {},
      ],
      45: [
        function (require, module, exports) {
          var matcher =
            /^(\d{4})(?:-?(\d{2})(?:-?(\d{2}))?)?(?:([ T])(\d{2}):?(\d{2})(?::?(\d{2})(?:[,\.](\d{1,}))?)?(?:(Z)|([+\-])(\d{2})(?::?(\d{2}))?)?)?$/
          ;(exports.parse = function (iso) {
            var numericKeys = [1, 5, 6, 7, 11, 12],
              arr = matcher.exec(iso),
              offset = 0
            if (!arr) return new Date(iso)
            for (var i = 0, val; (val = numericKeys[i]); i++)
              arr[val] = parseInt(arr[val], 10) || 0
            ;(arr[2] = parseInt(arr[2], 10) || 1),
              (arr[3] = parseInt(arr[3], 10) || 1),
              arr[2]--,
              (arr[8] = arr[8] ? (arr[8] + '00').substring(0, 3) : 0),
              ' ' == arr[4]
                ? (offset = new Date().getTimezoneOffset())
                : 'Z' !== arr[9] &&
                  arr[10] &&
                  ((offset = 60 * arr[11] + arr[12]),
                  '+' == arr[10] && (offset = 0 - offset))
            var millis = Date.UTC(
              arr[1],
              arr[2],
              arr[3],
              arr[5],
              arr[6] + offset,
              arr[7],
              arr[8]
            )
            return new Date(millis)
          }),
            (exports.is = function (string, strict) {
              return (
                (!strict || !1 !== /^\d{4}-\d{2}-\d{2}/.test(string)) &&
                matcher.test(string)
              )
            })
        },
        {},
      ],
      4: [
        function (require, module, exports) {
          var type = require('type'),
            has = Object.prototype.hasOwnProperty
          function string(obj, fn) {
            for (var i = 0; i < obj.length; ++i) fn(obj.charAt(i), i)
          }
          function object(obj, fn) {
            for (var key in obj) has.call(obj, key) && fn(key, obj[key])
          }
          function array(obj, fn) {
            for (var i = 0; i < obj.length; ++i) fn(obj[i], i)
          }
          module.exports = function (obj, fn) {
            switch (type(obj)) {
              case 'array':
                return array(obj, fn)
              case 'object':
                return 'number' == typeof obj.length
                  ? array(obj, fn)
                  : object(obj, fn)
              case 'string':
                return string(obj, fn)
            }
          }
        },
        { type: 43 },
      ],
      40: [
        function (require, module, exports) {
          var is = require('is'),
            isodate = require('isodate'),
            milliseconds = require('./milliseconds'),
            seconds = require('./seconds')
          function toMs(num) {
            return num < 315576e5 ? 1e3 * num : num
          }
          module.exports = function newDate(val) {
            return is.date(val)
              ? val
              : is.number(val)
              ? new Date(toMs(val))
              : isodate.is(val)
              ? isodate.parse(val)
              : milliseconds.is(val)
              ? milliseconds.parse(val)
              : seconds.is(val)
              ? seconds.parse(val)
              : new Date(val)
          }
        },
        { is: 47, isodate: 45, './milliseconds': 48, './seconds': 49 },
      ],
      47: [
        function (require, module, exports) {
          for (
            var isEmpty = require('is-empty'),
              typeOf = require('type'),
              types = [
                'arguments',
                'array',
                'boolean',
                'date',
                'element',
                'function',
                'null',
                'number',
                'object',
                'regexp',
                'string',
                'undefined',
              ],
              i = 0,
              type;
            (type = types[i]);
            i++
          )
            exports[type] = generate(type)
          function generate(type) {
            return function (value) {
              return type === typeOf(value)
            }
          }
          ;(exports.fn = exports.function),
            (exports.empty = isEmpty),
            (exports.nan = function (val) {
              return exports.number(val) && val != val
            })
        },
        { 'is-empty': 46, type: 43 },
      ],
      48: [
        function (require, module, exports) {
          var matcher = /\d{13}/
          ;(exports.is = function (string) {
            return matcher.test(string)
          }),
            (exports.parse = function (millis) {
              return (millis = parseInt(millis, 10)), new Date(millis)
            })
        },
        {},
      ],
      49: [
        function (require, module, exports) {
          var matcher = /\d{10}/
          ;(exports.is = function (string) {
            return matcher.test(string)
          }),
            (exports.parse = function (seconds) {
              var millis = 1e3 * parseInt(seconds, 10)
              return new Date(millis)
            })
        },
        {},
      ],
      30: [
        function (require, module, exports) {
          var inherit = require('./utils').inherit,
            Facade = require('./facade')
          function Alias(dictionary) {
            Facade.call(this, dictionary)
          }
          ;(module.exports = Alias),
            inherit(Alias, Facade),
            (Alias.prototype.type = Alias.prototype.action =
              function () {
                return 'alias'
              }),
            (Alias.prototype.from = Alias.prototype.previousId =
              function () {
                return this.field('previousId') || this.field('from')
              }),
            (Alias.prototype.to = Alias.prototype.userId =
              function () {
                return this.field('userId') || this.field('to')
              })
        },
        { './utils': 36, './facade': 29 },
      ],
      31: [
        function (require, module, exports) {
          var inherit = require('./utils').inherit,
            Facade = require('./facade'),
            newDate = require('new-date')
          function Group(dictionary) {
            Facade.call(this, dictionary)
          }
          ;(module.exports = Group),
            inherit(Group, Facade),
            (Group.prototype.type = Group.prototype.action =
              function () {
                return 'group'
              }),
            (Group.prototype.groupId = Facade.field('groupId')),
            (Group.prototype.created = function () {
              var created =
                this.proxy('traits.createdAt') ||
                this.proxy('traits.created') ||
                this.proxy('properties.createdAt') ||
                this.proxy('properties.created')
              if (created) return newDate(created)
            }),
            (Group.prototype.traits = function (aliases) {
              var ret = this.properties(),
                id = this.groupId()
              for (var alias in ((aliases = aliases || {}),
              id && (ret.id = id),
              aliases)) {
                var value =
                  null == this[alias]
                    ? this.proxy('traits.' + alias)
                    : this[alias]()
                null != value &&
                  ((ret[aliases[alias]] = value), delete ret[alias])
              }
              return ret
            }),
            (Group.prototype.properties = function () {
              return this.field('traits') || this.field('properties') || {}
            })
        },
        { './utils': 36, './facade': 29, 'new-date': 40 },
      ],
      32: [
        function (require, module, exports) {
          var Facade = require('./facade'),
            isEmail = require('is-email'),
            newDate = require('new-date'),
            utils = require('./utils'),
            get = require('obj-case'),
            trim = require('trim'),
            inherit = utils.inherit,
            clone = utils.clone,
            type = utils.type
          function Identify(dictionary) {
            Facade.call(this, dictionary)
          }
          ;(module.exports = Identify),
            inherit(Identify, Facade),
            (Identify.prototype.type = Identify.prototype.action =
              function () {
                return 'identify'
              }),
            (Identify.prototype.traits = function (aliases) {
              var ret = this.field('traits') || {},
                id = this.userId()
              for (var alias in ((aliases = aliases || {}),
              id && (ret.id = id),
              aliases)) {
                var value =
                  null == this[alias]
                    ? this.proxy('traits.' + alias)
                    : this[alias]()
                null != value &&
                  ((ret[aliases[alias]] = value),
                  alias !== aliases[alias] && delete ret[alias])
              }
              return ret
            }),
            (Identify.prototype.email = function () {
              var email = this.proxy('traits.email')
              if (email) return email
              var userId = this.userId()
              return isEmail(userId) ? userId : void 0
            }),
            (Identify.prototype.created = function () {
              var created =
                this.proxy('traits.created') || this.proxy('traits.createdAt')
              if (created) return newDate(created)
            }),
            (Identify.prototype.companyCreated = function () {
              var created =
                this.proxy('traits.company.created') ||
                this.proxy('traits.company.createdAt')
              if (created) return newDate(created)
            }),
            (Identify.prototype.name = function () {
              var name = this.proxy('traits.name')
              if ('string' == typeof name) return trim(name)
              var firstName = this.firstName(),
                lastName = this.lastName()
              return firstName && lastName
                ? trim(firstName + ' ' + lastName)
                : void 0
            }),
            (Identify.prototype.firstName = function () {
              var firstName = this.proxy('traits.firstName')
              if ('string' == typeof firstName) return trim(firstName)
              var name = this.proxy('traits.name')
              return 'string' == typeof name ? trim(name).split(' ')[0] : void 0
            }),
            (Identify.prototype.lastName = function () {
              var lastName = this.proxy('traits.lastName')
              if ('string' == typeof lastName) return trim(lastName)
              var name = this.proxy('traits.name')
              if ('string' == typeof name) {
                var space = trim(name).indexOf(' ')
                if (-1 !== space) return trim(name.substr(space + 1))
              }
            }),
            (Identify.prototype.uid = function () {
              return this.userId() || this.username() || this.email()
            }),
            (Identify.prototype.description = function () {
              return (
                this.proxy('traits.description') ||
                this.proxy('traits.background')
              )
            }),
            (Identify.prototype.age = function () {
              var date = this.birthday(),
                age = get(this.traits(), 'age'),
                now
              return null != age
                ? age
                : 'date' == type(date)
                ? new Date().getFullYear() - date.getFullYear()
                : void 0
            }),
            (Identify.prototype.avatar = function () {
              var traits = this.traits()
              return get(traits, 'avatar') || get(traits, 'photoUrl')
            }),
            (Identify.prototype.position = function () {
              var traits = this.traits()
              return get(traits, 'position') || get(traits, 'jobTitle')
            }),
            (Identify.prototype.username = Facade.proxy('traits.username')),
            (Identify.prototype.website = Facade.one('traits.website')),
            (Identify.prototype.websites = Facade.multi('traits.website')),
            (Identify.prototype.phone = Facade.one('traits.phone')),
            (Identify.prototype.phones = Facade.multi('traits.phone')),
            (Identify.prototype.address = Facade.proxy('traits.address')),
            (Identify.prototype.gender = Facade.proxy('traits.gender')),
            (Identify.prototype.birthday = Facade.proxy('traits.birthday'))
        },
        {
          './facade': 29,
          'is-email': 50,
          'new-date': 40,
          './utils': 36,
          'obj-case': 38,
          trim: 51,
        },
      ],
      50: [
        function (require, module, exports) {
          module.exports = isEmail
          var matcher = /.+\@.+\..+/
          function isEmail(string) {
            return matcher.test(string)
          }
        },
        {},
      ],
      51: [
        function (require, module, exports) {
          function trim(str) {
            return str.trim ? str.trim() : str.replace(/^\s*|\s*$/g, '')
          }
          ;((exports = module.exports = trim).left = function (str) {
            return str.trimLeft ? str.trimLeft() : str.replace(/^\s*/, '')
          }),
            (exports.right = function (str) {
              return str.trimRight ? str.trimRight() : str.replace(/\s*$/, '')
            })
        },
        {},
      ],
      33: [
        function (require, module, exports) {
          var inherit = require('./utils').inherit,
            clone = require('./utils').clone,
            type = require('./utils').type,
            Facade = require('./facade'),
            Identify = require('./identify'),
            isEmail = require('is-email'),
            get = require('obj-case')
          function Track(dictionary) {
            Facade.call(this, dictionary)
          }
          function currency(val) {
            if (val) {
              if ('number' == typeof val) return val
              if ('string' == typeof val)
                return (
                  (val = val.replace(/\$/g, '')),
                  (val = parseFloat(val)),
                  isNaN(val) ? void 0 : val
                )
            }
          }
          ;(module.exports = Track),
            inherit(Track, Facade),
            (Track.prototype.type = Track.prototype.action =
              function () {
                return 'track'
              }),
            (Track.prototype.event = Facade.field('event')),
            (Track.prototype.value = Facade.proxy('properties.value')),
            (Track.prototype.category = Facade.proxy('properties.category')),
            (Track.prototype.country = Facade.proxy('properties.country')),
            (Track.prototype.state = Facade.proxy('properties.state')),
            (Track.prototype.city = Facade.proxy('properties.city')),
            (Track.prototype.zip = Facade.proxy('properties.zip')),
            (Track.prototype.id = Facade.proxy('properties.id')),
            (Track.prototype.sku = Facade.proxy('properties.sku')),
            (Track.prototype.tax = Facade.proxy('properties.tax')),
            (Track.prototype.name = Facade.proxy('properties.name')),
            (Track.prototype.price = Facade.proxy('properties.price')),
            (Track.prototype.total = Facade.proxy('properties.total')),
            (Track.prototype.coupon = Facade.proxy('properties.coupon')),
            (Track.prototype.shipping = Facade.proxy('properties.shipping')),
            (Track.prototype.orderId = function () {
              return (
                this.proxy('properties.id') || this.proxy('properties.orderId')
              )
            }),
            (Track.prototype.subtotal = function () {
              var subtotal = get(this.properties(), 'subtotal'),
                total = this.total(),
                n
              return (
                subtotal ||
                (total
                  ? ((n = this.tax()) && (total -= n),
                    (n = this.shipping()) && (total -= n),
                    total)
                  : 0)
              )
            }),
            (Track.prototype.products = function () {
              var props = this.properties(),
                products = get(props, 'products')
              return 'array' == type(products) ? products : []
            }),
            (Track.prototype.quantity = function () {
              var props
              return (this.obj.properties || {}).quantity || 1
            }),
            (Track.prototype.currency = function () {
              var props
              return (this.obj.properties || {}).currency || 'USD'
            }),
            (Track.prototype.referrer = Facade.proxy('properties.referrer')),
            (Track.prototype.query = Facade.proxy('options.query')),
            (Track.prototype.properties = function (aliases) {
              var ret = this.field('properties') || {}
              for (var alias in (aliases = aliases || {})) {
                var value =
                  null == this[alias]
                    ? this.proxy('properties.' + alias)
                    : this[alias]()
                null != value &&
                  ((ret[aliases[alias]] = value), delete ret[alias])
              }
              return ret
            }),
            (Track.prototype.username = function () {
              return (
                this.proxy('traits.username') ||
                this.proxy('properties.username') ||
                this.userId() ||
                this.sessionId()
              )
            }),
            (Track.prototype.email = function () {
              var email = this.proxy('traits.email')
              if ((email = email || this.proxy('properties.email')))
                return email
              var userId = this.userId()
              return isEmail(userId) ? userId : void 0
            }),
            (Track.prototype.revenue = function () {
              var revenue = this.proxy('properties.revenue'),
                event = this.event()
              return (
                !revenue &&
                  event &&
                  event.match(/completed ?order/i) &&
                  (revenue = this.proxy('properties.total')),
                currency(revenue)
              )
            }),
            (Track.prototype.cents = function () {
              var revenue = this.revenue()
              return 'number' != typeof revenue
                ? this.value() || 0
                : 100 * revenue
            }),
            (Track.prototype.identify = function () {
              var json = this.json()
              return (json.traits = this.traits()), new Identify(json)
            })
        },
        {
          './utils': 36,
          './facade': 29,
          './identify': 32,
          'is-email': 50,
          'obj-case': 38,
        },
      ],
      34: [
        function (require, module, exports) {
          var inherit = require('./utils').inherit,
            Facade = require('./facade'),
            Track = require('./track')
          function Page(dictionary) {
            Facade.call(this, dictionary)
          }
          ;(module.exports = Page),
            inherit(Page, Facade),
            (Page.prototype.type = Page.prototype.action =
              function () {
                return 'page'
              }),
            (Page.prototype.category = Facade.field('category')),
            (Page.prototype.name = Facade.field('name')),
            (Page.prototype.properties = function () {
              var props = this.field('properties') || {},
                category = this.category(),
                name = this.name()
              return (
                category && (props.category = category),
                name && (props.name = name),
                props
              )
            }),
            (Page.prototype.fullName = function () {
              var category = this.category(),
                name = this.name()
              return name && category ? category + ' ' + name : name
            }),
            (Page.prototype.event = function (name) {
              return name ? 'Viewed ' + name + ' Page' : 'Loaded a Page'
            }),
            (Page.prototype.track = function (name) {
              var props = this.properties()
              return new Track({
                event: this.event(name),
                timestamp: this.timestamp(),
                context: this.context(),
                properties: props,
              })
            })
        },
        { './utils': 36, './facade': 29, './track': 33 },
      ],
      35: [
        function (require, module, exports) {
          var inherit = require('./utils').inherit,
            Page = require('./page'),
            Track = require('./track')
          function Screen(dictionary) {
            Page.call(this, dictionary)
          }
          ;(module.exports = Screen),
            inherit(Screen, Page),
            (Screen.prototype.type = Screen.prototype.action =
              function () {
                return 'screen'
              }),
            (Screen.prototype.event = function (name) {
              return name ? 'Viewed ' + name + ' Screen' : 'Loaded a Screen'
            }),
            (Screen.prototype.track = function (name) {
              var props = this.properties()
              return new Track({
                event: this.event(name),
                timestamp: this.timestamp(),
                context: this.context(),
                properties: props,
              })
            })
        },
        { './utils': 36, './page': 34, './track': 33 },
      ],
      8: [
        function (require, module, exports) {
          module.exports = function after(times, func) {
            return times <= 0
              ? func()
              : function () {
                  if (--times < 1) return func.apply(this, arguments)
                }
          }
        },
        {},
      ],
      9: [
        function (require, module, exports) {
          try {
            var bind = require('bind')
          } catch (e) {
            var bind = require('bind-component')
          }
          var bindAll = require('bind-all')
          function bindMethods(obj, methods) {
            methods = [].slice.call(arguments, 1)
            for (var i = 0, method; (method = methods[i]); i++)
              obj[method] = bind(obj, obj[method])
            return obj
          }
          ;(module.exports = exports = bind),
            (exports.all = bindAll),
            (exports.methods = bindMethods)
        },
        { bind: 52, 'bind-all': 53 },
      ],
      52: [
        function (require, module, exports) {
          var slice = [].slice
          module.exports = function (obj, fn) {
            if (
              ('string' == typeof fn && (fn = obj[fn]), 'function' != typeof fn)
            )
              throw new Error('bind() requires a function')
            var args = slice.call(arguments, 2)
            return function () {
              return fn.apply(obj, args.concat(slice.call(arguments)))
            }
          }
        },
        {},
      ],
      53: [
        function (require, module, exports) {
          try {
            var bind = require('bind'),
              type = require('type')
          } catch (e) {
            var bind = require('bind-component'),
              type = require('type-component')
          }
          module.exports = function (obj) {
            for (var key in obj) {
              var val = obj[key]
              'function' === type(val) && (obj[key] = bind(obj, obj[key]))
            }
            return obj
          }
        },
        { bind: 52, type: 43 },
      ],
      10: [
        function (require, module, exports) {
          var next = require('next-tick')
          function callback(fn) {
            'function' == typeof fn && fn()
          }
          ;(module.exports = callback),
            (callback.async = function (fn, wait) {
              if ('function' == typeof fn)
                return wait ? void setTimeout(fn, wait) : next(fn)
            }),
            (callback.sync = callback)
        },
        { 'next-tick': 54 },
      ],
      54: [
        function (require, module, exports) {
          'use strict'
          if ('function' == typeof setImmediate)
            module.exports = function (f) {
              setImmediate(f)
            }
          else if (
            'undefined' != typeof process &&
            'function' == typeof process.nextTick
          )
            module.exports = process.nextTick
          else if (
            'undefined' == typeof window ||
            window.ActiveXObject ||
            !window.postMessage
          )
            module.exports = function (f) {
              setTimeout(f)
            }
          else {
            var q = []
            window.addEventListener(
              'message',
              function () {
                for (var i = 0; i < q.length; )
                  try {
                    q[i++]()
                  } catch (e) {
                    throw ((q = q.slice(i)), window.postMessage('tic!', '*'), e)
                  }
                q.length = 0
              },
              !0
            ),
              (module.exports = function (fn) {
                q.length || window.postMessage('tic!', '*'), q.push(fn)
              })
          }
        },
        {},
      ],
      11: [
        function (require, module, exports) {
          var type
          try {
            type = require('type')
          } catch (e) {
            type = require('type-component')
          }
          function clone(obj) {
            switch (type(obj)) {
              case 'object':
                var copy = {}
                for (var key in obj)
                  obj.hasOwnProperty(key) && (copy[key] = clone(obj[key]))
                return copy
              case 'array':
                for (
                  var copy = new Array(obj.length), i = 0, l = obj.length;
                  i < l;
                  i++
                )
                  copy[i] = clone(obj[i])
                return copy
              case 'regexp':
                var flags = ''
                return (
                  (flags += obj.multiline ? 'm' : ''),
                  (flags += obj.global ? 'g' : ''),
                  (flags += obj.ignoreCase ? 'i' : ''),
                  new RegExp(obj.source, flags)
                )
              case 'date':
                return new Date(obj.getTime())
              default:
                return obj
            }
          }
          module.exports = clone
        },
        { type: 43 },
      ],
      12: [
        function (require, module, exports) {
          var bind = require('bind'),
            clone = require('clone'),
            cookie = require('cookie'),
            debug = require('debug')('analytics.js:cookie'),
            defaults = require('defaults'),
            json = require('json'),
            topDomain = require('top-domain')
          function Cookie(options) {
            this.options(options)
          }
          ;(Cookie.prototype.options = function (options) {
            if (0 === arguments.length) return this._options
            options = options || {}
            var domain = '.' + topDomain(window.location.href)
            '.' === domain && (domain = null),
              (this._options = defaults(options, {
                maxage: 31536e6,
                path: '/',
                domain: domain,
              })),
              this.set('ajs:test', !0),
              this.get('ajs:test') ||
                (debug('fallback to domain=null'),
                (this._options.domain = null)),
              this.remove('ajs:test')
          }),
            (Cookie.prototype.set = function (key, value) {
              try {
                return (
                  (value = json.stringify(value)),
                  cookie(key, value, clone(this._options)),
                  !0
                )
              } catch (e) {
                return !1
              }
            }),
            (Cookie.prototype.get = function (key) {
              try {
                var value = cookie(key)
                return (value = value ? json.parse(value) : null)
              } catch (e) {
                return null
              }
            }),
            (Cookie.prototype.remove = function (key) {
              try {
                return cookie(key, null, clone(this._options)), !0
              } catch (e) {
                return !1
              }
            }),
            (module.exports = bind.all(new Cookie())),
            (module.exports.Cookie = Cookie)
        },
        {
          bind: 9,
          clone: 11,
          cookie: 55,
          debug: 13,
          defaults: 14,
          json: 56,
          'top-domain': 57,
        },
      ],
      55: [
        function (require, module, exports) {
          var debug = require('debug')('cookie')
          function set(name, value, options) {
            options = options || {}
            var str = encode(name) + '=' + encode(value)
            null == value && (options.maxage = -1),
              options.maxage &&
                (options.expires = new Date(+new Date() + options.maxage)),
              options.path && (str += '; path=' + options.path),
              options.domain && (str += '; domain=' + options.domain),
              options.expires &&
                (str += '; expires=' + options.expires.toUTCString()),
              options.secure && (str += '; secure'),
              (document.cookie = str)
          }
          function all() {
            return parse(document.cookie)
          }
          function get(name) {
            return all()[name]
          }
          function parse(str) {
            var obj = {},
              pairs = str.split(/ *; */),
              pair
            if ('' == pairs[0]) return obj
            for (var i = 0; i < pairs.length; ++i)
              obj[decode((pair = pairs[i].split('='))[0])] = decode(pair[1])
            return obj
          }
          function encode(value) {
            try {
              return encodeURIComponent(value)
            } catch (e) {
              debug('error `encode(%o)` - %o', value, e)
            }
          }
          function decode(value) {
            try {
              return decodeURIComponent(value)
            } catch (e) {
              debug('error `decode(%o)` - %o', value, e)
            }
          }
          module.exports = function (name, value, options) {
            switch (arguments.length) {
              case 3:
              case 2:
                return set(name, value, options)
              case 1:
                return get(name)
              default:
                return all()
            }
          }
        },
        { debug: 13 },
      ],
      13: [
        function (require, module, exports) {
          'undefined' == typeof window
            ? (module.exports = require('./lib/debug'))
            : (module.exports = require('./debug'))
        },
        { './lib/debug': 58, './debug': 59 },
      ],
      58: [
        function (require, module, exports) {
          var tty = require('tty')
          module.exports = debug
          var names = [],
            skips = []
          ;(process.env.DEBUG || '').split(/[\s,]+/).forEach(function (name) {
            '-' === (name = name.replace('*', '.*?'))[0]
              ? skips.push(new RegExp('^' + name.substr(1) + '$'))
              : names.push(new RegExp('^' + name + '$'))
          })
          var colors = [6, 2, 3, 4, 5, 1],
            prev = {},
            prevColor = 0,
            isatty = tty.isatty(2)
          function color() {
            return colors[prevColor++ % colors.length]
          }
          function humanize(ms) {
            var sec = 1e3,
              min = 6e4,
              hour = 36e5
            return ms >= 36e5
              ? (ms / 36e5).toFixed(1) + 'h'
              : ms >= 6e4
              ? (ms / 6e4).toFixed(1) + 'm'
              : ms >= 1e3
              ? ((ms / 1e3) | 0) + 's'
              : ms + 'ms'
          }
          function debug(name) {
            function disabled() {}
            disabled.enabled = !1
            var match = skips.some(function (re) {
              return re.test(name)
            })
            if (match) return disabled
            if (
              !(match = names.some(function (re) {
                return re.test(name)
              }))
            )
              return disabled
            var c = color()
            function colored(fmt) {
              fmt = coerce(fmt)
              var curr = new Date(),
                ms = curr - (prev[name] || curr)
              ;(prev[name] = curr),
                (fmt =
                  '  [9' +
                  c +
                  'm' +
                  name +
                  ' [3' +
                  c +
                  'm[90m' +
                  fmt +
                  '[3' +
                  c +
                  'm +' +
                  humanize(ms) +
                  '[0m'),
                console.error.apply(this, arguments)
            }
            function plain(fmt) {
              ;(fmt = coerce(fmt)),
                (fmt = new Date().toUTCString() + ' ' + name + ' ' + fmt),
                console.error.apply(this, arguments)
            }
            return (
              (colored.enabled = plain.enabled = !0),
              isatty || process.env.DEBUG_COLORS ? colored : plain
            )
          }
          function coerce(val) {
            return val instanceof Error ? val.stack || val.message : val
          }
        },
        {},
      ],
      59: [
        function (require, module, exports) {
          function debug(name) {
            return debug.enabled(name)
              ? function (fmt) {
                  fmt = coerce(fmt)
                  var curr = new Date(),
                    ms = curr - (debug[name] || curr)
                  ;(debug[name] = curr),
                    (fmt = name + ' ' + fmt + ' +' + debug.humanize(ms)),
                    window.console &&
                      console.log &&
                      Function.prototype.apply.call(
                        console.log,
                        console,
                        arguments
                      )
                }
              : function () {}
          }
          function coerce(val) {
            return val instanceof Error ? val.stack || val.message : val
          }
          ;(module.exports = debug),
            (debug.names = []),
            (debug.skips = []),
            (debug.enable = function (name) {
              try {
                localStorage.debug = name
              } catch (e) {}
              for (
                var split = (name || '').split(/[\s,]+/),
                  len = split.length,
                  i = 0;
                i < len;
                i++
              )
                '-' === (name = split[i].replace('*', '.*?'))[0]
                  ? debug.skips.push(new RegExp('^' + name.substr(1) + '$'))
                  : debug.names.push(new RegExp('^' + name + '$'))
            }),
            (debug.disable = function () {
              debug.enable('')
            }),
            (debug.humanize = function (ms) {
              var sec = 1e3,
                min = 6e4,
                hour = 36e5
              return ms >= 36e5
                ? (ms / 36e5).toFixed(1) + 'h'
                : ms >= 6e4
                ? (ms / 6e4).toFixed(1) + 'm'
                : ms >= 1e3
                ? ((ms / 1e3) | 0) + 's'
                : ms + 'ms'
            }),
            (debug.enabled = function (name) {
              for (var i = 0, len = debug.skips.length; i < len; i++)
                if (debug.skips[i].test(name)) return !1
              for (var i = 0, len = debug.names.length; i < len; i++)
                if (debug.names[i].test(name)) return !0
              return !1
            })
          try {
            window.localStorage && debug.enable(localStorage.debug)
          } catch (e) {}
        },
        {},
      ],
      14: [
        function (require, module, exports) {
          'use strict'
          var defaults = function (dest, src, recursive) {
            for (var prop in src)
              recursive &&
              dest[prop] instanceof Object &&
              src[prop] instanceof Object
                ? (dest[prop] = defaults(dest[prop], src[prop], !0))
                : prop in dest || (dest[prop] = src[prop])
            return dest
          }
          module.exports = defaults
        },
        {},
      ],
      56: [
        function (require, module, exports) {
          var json = window.JSON || {},
            stringify = json.stringify,
            parse = json.parse
          module.exports = parse && stringify ? JSON : require('json-fallback')
        },
        { 'json-fallback': 60 },
      ],
      60: [
        function (require, module, exports) {
          !(function () {
            'use strict'
            var JSON = (module.exports = {}),
              cx,
              escapable,
              gap,
              indent,
              meta,
              rep
            function f(n) {
              return n < 10 ? '0' + n : n
            }
            function quote(string) {
              return (
                (escapable.lastIndex = 0),
                escapable.test(string)
                  ? '"' +
                    string.replace(escapable, function (a) {
                      var c = meta[a]
                      return 'string' == typeof c
                        ? c
                        : '\\u' +
                            ('0000' + a.charCodeAt(0).toString(16)).slice(-4)
                    }) +
                    '"'
                  : '"' + string + '"'
              )
            }
            function str(key, holder) {
              var i,
                k,
                v,
                length,
                mind = gap,
                partial,
                value = holder[key]
              switch (
                (value &&
                  'object' == typeof value &&
                  'function' == typeof value.toJSON &&
                  (value = value.toJSON(key)),
                'function' == typeof rep &&
                  (value = rep.call(holder, key, value)),
                typeof value)
              ) {
                case 'string':
                  return quote(value)
                case 'number':
                  return isFinite(value) ? String(value) : 'null'
                case 'boolean':
                case 'null':
                  return String(value)
                case 'object':
                  if (!value) return 'null'
                  if (
                    ((gap += indent),
                    (partial = []),
                    '[object Array]' === Object.prototype.toString.apply(value))
                  ) {
                    for (length = value.length, i = 0; i < length; i += 1)
                      partial[i] = str(i, value) || 'null'
                    return (
                      (v =
                        0 === partial.length
                          ? '[]'
                          : gap
                          ? '[\n' +
                            gap +
                            partial.join(',\n' + gap) +
                            '\n' +
                            mind +
                            ']'
                          : '[' + partial.join(',') + ']'),
                      (gap = mind),
                      v
                    )
                  }
                  if (rep && 'object' == typeof rep)
                    for (length = rep.length, i = 0; i < length; i += 1)
                      'string' == typeof rep[i] &&
                        (v = str((k = rep[i]), value)) &&
                        partial.push(quote(k) + (gap ? ': ' : ':') + v)
                  else
                    for (k in value)
                      Object.prototype.hasOwnProperty.call(value, k) &&
                        (v = str(k, value)) &&
                        partial.push(quote(k) + (gap ? ': ' : ':') + v)
                  return (
                    (v =
                      0 === partial.length
                        ? '{}'
                        : gap
                        ? '{\n' +
                          gap +
                          partial.join(',\n' + gap) +
                          '\n' +
                          mind +
                          '}'
                        : '{' + partial.join(',') + '}'),
                    (gap = mind),
                    v
                  )
              }
            }
            'function' != typeof Date.prototype.toJSON &&
              ((Date.prototype.toJSON = function () {
                return isFinite(this.valueOf())
                  ? this.getUTCFullYear() +
                      '-' +
                      f(this.getUTCMonth() + 1) +
                      '-' +
                      f(this.getUTCDate()) +
                      'T' +
                      f(this.getUTCHours()) +
                      ':' +
                      f(this.getUTCMinutes()) +
                      ':' +
                      f(this.getUTCSeconds()) +
                      'Z'
                  : null
              }),
              (String.prototype.toJSON =
                Number.prototype.toJSON =
                Boolean.prototype.toJSON =
                  function () {
                    return this.valueOf()
                  })),
              'function' != typeof JSON.stringify &&
                ((escapable =
                  /[\\\"\x00-\x1f\x7f-\x9f\u00ad\u0600-\u0604\u070f\u17b4\u17b5\u200c-\u200f\u2028-\u202f\u2060-\u206f\ufeff\ufff0-\uffff]/g),
                (meta = {
                  '\b': '\\b',
                  '\t': '\\t',
                  '\n': '\\n',
                  '\f': '\\f',
                  '\r': '\\r',
                  '"': '\\"',
                  '\\': '\\\\',
                }),
                (JSON.stringify = function (value, replacer, space) {
                  var i
                  if (((gap = ''), (indent = ''), 'number' == typeof space))
                    for (i = 0; i < space; i += 1) indent += ' '
                  else 'string' == typeof space && (indent = space)
                  if (
                    ((rep = replacer),
                    replacer &&
                      'function' != typeof replacer &&
                      ('object' != typeof replacer ||
                        'number' != typeof replacer.length))
                  )
                    throw new Error('JSON.stringify')
                  return str('', { '': value })
                })),
              'function' != typeof JSON.parse &&
                ((cx =
                  /[\u0000\u00ad\u0600-\u0604\u070f\u17b4\u17b5\u200c-\u200f\u2028-\u202f\u2060-\u206f\ufeff\ufff0-\uffff]/g),
                (JSON.parse = function (text, reviver) {
                  var j
                  function walk(holder, key) {
                    var k,
                      v,
                      value = holder[key]
                    if (value && 'object' == typeof value)
                      for (k in value)
                        Object.prototype.hasOwnProperty.call(value, k) &&
                          (void 0 !== (v = walk(value, k))
                            ? (value[k] = v)
                            : delete value[k])
                    return reviver.call(holder, key, value)
                  }
                  if (
                    ((text = String(text)),
                    (cx.lastIndex = 0),
                    cx.test(text) &&
                      (text = text.replace(cx, function (a) {
                        return (
                          '\\u' +
                          ('0000' + a.charCodeAt(0).toString(16)).slice(-4)
                        )
                      })),
                    /^[\],:{}\s]*$/.test(
                      text
                        .replace(/\\(?:["\\\/bfnrt]|u[0-9a-fA-F]{4})/g, '@')
                        .replace(
                          /"[^"\\\n\r]*"|true|false|null|-?\d+(?:\.\d*)?(?:[eE][+\-]?\d+)?/g,
                          ']'
                        )
                        .replace(/(?:^|:|,)(?:\s*\[)+/g, '')
                    ))
                  )
                    return (
                      (j = eval('(' + text + ')')),
                      'function' == typeof reviver ? walk({ '': j }, '') : j
                    )
                  throw new SyntaxError('JSON.parse')
                }))
          })()
        },
        {},
      ],
      57: [
        function (require, module, exports) {
          var parse = require('url').parse,
            cookie = require('cookie')
          function domain(url) {
            for (
              var cookie = exports.cookie, levels = exports.levels(url), i = 0;
              i < levels.length;
              ++i
            ) {
              var cname = '__tld__',
                domain = levels[i],
                opts = { domain: '.' + domain }
              if ((cookie(cname, 1, opts), cookie(cname)))
                return cookie(cname, null, opts), domain
            }
            return ''
          }
          ;((exports = module.exports = domain).cookie = cookie),
            (domain.levels = function (url) {
              var host,
                parts = parse(url).hostname.split('.'),
                last = parts[parts.length - 1],
                levels = []
              if (4 == parts.length && parseInt(last, 10) == last) return levels
              if (1 >= parts.length) return levels
              for (var i = parts.length - 2; 0 <= i; --i)
                levels.push(parts.slice(i).join('.'))
              return levels
            })
        },
        { url: 61, cookie: 62 },
      ],
      61: [
        function (require, module, exports) {
          function port(protocol) {
            switch (protocol) {
              case 'http:':
                return 80
              case 'https:':
                return 443
              default:
                return location.port
            }
          }
          ;(exports.parse = function (url) {
            var a = document.createElement('a')
            return (
              (a.href = url),
              {
                href: a.href,
                host: a.host || location.host,
                port:
                  '0' === a.port || '' === a.port ? port(a.protocol) : a.port,
                hash: a.hash,
                hostname: a.hostname || location.hostname,
                pathname:
                  '/' != a.pathname.charAt(0) ? '/' + a.pathname : a.pathname,
                protocol:
                  a.protocol && ':' != a.protocol
                    ? a.protocol
                    : location.protocol,
                search: a.search,
                query: a.search.slice(1),
              }
            )
          }),
            (exports.isAbsolute = function (url) {
              return 0 == url.indexOf('//') || !!~url.indexOf('://')
            }),
            (exports.isRelative = function (url) {
              return !exports.isAbsolute(url)
            }),
            (exports.isCrossDomain = function (url) {
              url = exports.parse(url)
              var location = exports.parse(window.location.href)
              return (
                url.hostname !== location.hostname ||
                url.port !== location.port ||
                url.protocol !== location.protocol
              )
            })
        },
        {},
      ],
      62: [
        function (require, module, exports) {
          var debug = require('debug')('cookie')
          function set(name, value, options) {
            options = options || {}
            var str = encode(name) + '=' + encode(value)
            null == value && (options.maxage = -1),
              options.maxage &&
                (options.expires = new Date(+new Date() + options.maxage)),
              options.path && (str += '; path=' + options.path),
              options.domain && (str += '; domain=' + options.domain),
              options.expires &&
                (str += '; expires=' + options.expires.toUTCString()),
              options.secure && (str += '; secure'),
              (document.cookie = str)
          }
          function all() {
            var str
            try {
              str = document.cookie
            } catch (err) {
              return (
                'undefined' != typeof console &&
                  'function' == typeof console.error &&
                  console.error(err.stack || err),
                {}
              )
            }
            return parse(str)
          }
          function get(name) {
            return all()[name]
          }
          function parse(str) {
            var obj = {},
              pairs = str.split(/ *; */),
              pair
            if ('' == pairs[0]) return obj
            for (var i = 0; i < pairs.length; ++i)
              obj[decode((pair = pairs[i].split('='))[0])] = decode(pair[1])
            return obj
          }
          function encode(value) {
            try {
              return encodeURIComponent(value)
            } catch (e) {
              debug('error `encode(%o)` - %o', value, e)
            }
          }
          function decode(value) {
            try {
              return decodeURIComponent(value)
            } catch (e) {
              debug('error `decode(%o)` - %o', value, e)
            }
          }
          module.exports = function (name, value, options) {
            switch (arguments.length) {
              case 3:
              case 2:
                return set(name, value, options)
              case 1:
                return get(name)
              default:
                return all()
            }
          }
        },
        { debug: 13 },
      ],
      15: [
        function (require, module, exports) {
          var Entity = require('./entity'),
            bind = require('bind'),
            debug = require('debug')('analytics:group'),
            inherit = require('inherit')
          function Group(options) {
            ;(this.defaults = Group.defaults),
              (this.debug = debug),
              Entity.call(this, options)
          }
          ;(Group.defaults = {
            persist: !0,
            cookie: { key: 'ajs_group_id' },
            localStorage: { key: 'ajs_group_properties' },
          }),
            inherit(Group, Entity),
            (module.exports = bind.all(new Group())),
            (module.exports.Group = Group)
        },
        { './entity': 63, bind: 9, debug: 13, inherit: 64 },
      ],
      63: [
        function (require, module, exports) {
          var clone = require('clone'),
            cookie = require('./cookie'),
            debug = require('debug')('analytics:entity'),
            defaults = require('defaults'),
            extend = require('extend'),
            memory = require('./memory'),
            store = require('./store'),
            isodateTraverse = require('isodate-traverse')
          function Entity(options) {
            this.options(options), this.initialize()
          }
          ;(module.exports = Entity),
            (Entity.prototype.initialize = function () {
              if ((cookie.set('ajs:cookies', !0), cookie.get('ajs:cookies')))
                return (
                  cookie.remove('ajs:cookies'), void (this._storage = cookie)
                )
              store.enabled
                ? (this._storage = store)
                : (debug(
                    'warning using memory store both cookies and localStorage are disabled'
                  ),
                  (this._storage = memory))
            }),
            (Entity.prototype.storage = function () {
              return this._storage
            }),
            (Entity.prototype.options = function (options) {
              if (0 === arguments.length) return this._options
              this._options = defaults(options || {}, this.defaults || {})
            }),
            (Entity.prototype.id = function (id) {
              switch (arguments.length) {
                case 0:
                  return this._getId()
                case 1:
                  return this._setId(id)
              }
            }),
            (Entity.prototype._getId = function () {
              var ret = this._options.persist
                ? this.storage().get(this._options.cookie.key)
                : this._id
              return void 0 === ret ? null : ret
            }),
            (Entity.prototype._setId = function (id) {
              this._options.persist
                ? this.storage().set(this._options.cookie.key, id)
                : (this._id = id)
            }),
            (Entity.prototype.properties = Entity.prototype.traits =
              function (traits) {
                switch (arguments.length) {
                  case 0:
                    return this._getTraits()
                  case 1:
                    return this._setTraits(traits)
                }
              }),
            (Entity.prototype._getTraits = function () {
              var ret = this._options.persist
                ? store.get(this._options.localStorage.key)
                : this._traits
              return ret ? isodateTraverse(clone(ret)) : {}
            }),
            (Entity.prototype._setTraits = function (traits) {
              ;(traits = traits || {}),
                this._options.persist
                  ? store.set(this._options.localStorage.key, traits)
                  : (this._traits = traits)
            }),
            (Entity.prototype.identify = function (id, traits) {
              traits = traits || {}
              var current = this.id()
              ;(null !== current && current !== id) ||
                (traits = extend(this.traits(), traits)),
                id && this.id(id),
                this.debug('identify %o, %o', id, traits),
                this.traits(traits),
                this.save()
            }),
            (Entity.prototype.save = function () {
              return (
                !!this._options.persist &&
                (cookie.set(this._options.cookie.key, this.id()),
                store.set(this._options.localStorage.key, this.traits()),
                !0)
              )
            }),
            (Entity.prototype.logout = function () {
              this.id(null),
                this.traits({}),
                cookie.remove(this._options.cookie.key),
                store.remove(this._options.localStorage.key)
            }),
            (Entity.prototype.reset = function () {
              this.logout(), this.options({})
            }),
            (Entity.prototype.load = function () {
              this.id(cookie.get(this._options.cookie.key)),
                this.traits(store.get(this._options.localStorage.key))
            })
        },
        {
          clone: 11,
          './cookie': 12,
          debug: 13,
          defaults: 14,
          extend: 65,
          './memory': 19,
          './store': 26,
          'isodate-traverse': 39,
        },
      ],
      65: [
        function (require, module, exports) {
          module.exports = function extend(object) {
            for (
              var args = Array.prototype.slice.call(arguments, 1),
                i = 0,
                source;
              (source = args[i]);
              i++
            )
              if (source)
                for (var property in source) object[property] = source[property]
            return object
          }
        },
        {},
      ],
      19: [
        function (require, module, exports) {
          var bind = require('bind'),
            clone = require('clone'),
            has = Object.prototype.hasOwnProperty
          function Memory() {
            this.store = {}
          }
          ;(module.exports = bind.all(new Memory())),
            (Memory.prototype.set = function (key, value) {
              return (this.store[key] = clone(value)), !0
            }),
            (Memory.prototype.get = function (key) {
              if (has.call(this.store, key)) return clone(this.store[key])
            }),
            (Memory.prototype.remove = function (key) {
              return delete this.store[key], !0
            })
        },
        { bind: 9, clone: 11 },
      ],
      26: [
        function (require, module, exports) {
          var bind = require('bind'),
            defaults = require('defaults'),
            store = require('store.js')
          function Store(options) {
            this.options(options)
          }
          ;(Store.prototype.options = function (options) {
            if (0 === arguments.length) return this._options
            defaults((options = options || {}), { enabled: !0 }),
              (this.enabled = options.enabled && store.enabled),
              (this._options = options)
          }),
            (Store.prototype.set = function (key, value) {
              return !!this.enabled && store.set(key, value)
            }),
            (Store.prototype.get = function (key) {
              return this.enabled ? store.get(key) : null
            }),
            (Store.prototype.remove = function (key) {
              return !!this.enabled && store.remove(key)
            }),
            (module.exports = bind.all(new Store())),
            (module.exports.Store = Store)
        },
        { bind: 9, defaults: 14, 'store.js': 66 },
      ],
      66: [
        function (require, module, exports) {
          var json = require('json'),
            store = {},
            win = window,
            doc = win.document,
            localStorageName = 'localStorage',
            namespace = '__storejs__',
            storage
          function isLocalStorageNameSupported() {
            try {
              return 'localStorage' in win && win.localStorage
            } catch (err) {
              return !1
            }
          }
          if (
            ((store.disabled = !1),
            (store.set = function (key, value) {}),
            (store.get = function (key) {}),
            (store.remove = function (key) {}),
            (store.clear = function () {}),
            (store.transact = function (key, defaultVal, transactionFn) {
              var val = store.get(key)
              null == transactionFn &&
                ((transactionFn = defaultVal), (defaultVal = null)),
                void 0 === val && (val = defaultVal || {}),
                transactionFn(val),
                store.set(key, val)
            }),
            (store.getAll = function () {}),
            (store.serialize = function (value) {
              return json.stringify(value)
            }),
            (store.deserialize = function (value) {
              if ('string' == typeof value)
                try {
                  return json.parse(value)
                } catch (e) {
                  return value || void 0
                }
            }),
            isLocalStorageNameSupported())
          )
            (storage = win.localStorage),
              (store.set = function (key, val) {
                return void 0 === val
                  ? store.remove(key)
                  : (storage.setItem(key, store.serialize(val)), val)
              }),
              (store.get = function (key) {
                return store.deserialize(storage.getItem(key))
              }),
              (store.remove = function (key) {
                storage.removeItem(key)
              }),
              (store.clear = function () {
                storage.clear()
              }),
              (store.getAll = function () {
                for (var ret = {}, i = 0; i < storage.length; ++i) {
                  var key = storage.key(i)
                  ret[key] = store.get(key)
                }
                return ret
              })
          else if (doc.documentElement.addBehavior) {
            var storageOwner, storageContainer
            try {
              ;(storageContainer = new ActiveXObject('htmlfile')).open(),
                storageContainer.write(
                  '<script>document.w=window</script><iframe src="/favicon.ico"></iframe>'
                ),
                storageContainer.close(),
                (storageOwner = storageContainer.w.frames[0].document),
                (storage = storageOwner.createElement('div'))
            } catch (e) {
              ;(storage = doc.createElement('div')), (storageOwner = doc.body)
            }
            function withIEStorage(storeFunction) {
              return function () {
                var args = Array.prototype.slice.call(arguments, 0)
                args.unshift(storage),
                  storageOwner.appendChild(storage),
                  storage.addBehavior('#default#userData'),
                  storage.load('localStorage')
                var result = storeFunction.apply(store, args)
                return storageOwner.removeChild(storage), result
              }
            }
            var forbiddenCharsRegex = new RegExp(
              '[!"#$%&\'()*+,/\\\\:;<=>?@[\\]^`{|}~]',
              'g'
            )
            function ieKeyFix(key) {
              return key.replace(forbiddenCharsRegex, '___')
            }
            ;(store.set = withIEStorage(function (storage, key, val) {
              return (
                (key = ieKeyFix(key)),
                void 0 === val
                  ? store.remove(key)
                  : (storage.setAttribute(key, store.serialize(val)),
                    storage.save('localStorage'),
                    val)
              )
            })),
              (store.get = withIEStorage(function (storage, key) {
                return (
                  (key = ieKeyFix(key)),
                  store.deserialize(storage.getAttribute(key))
                )
              })),
              (store.remove = withIEStorage(function (storage, key) {
                ;(key = ieKeyFix(key)),
                  storage.removeAttribute(key),
                  storage.save('localStorage')
              })),
              (store.clear = withIEStorage(function (storage) {
                var attributes = storage.XMLDocument.documentElement.attributes
                storage.load('localStorage')
                for (var i = 0, attr; (attr = attributes[i]); i++)
                  storage.removeAttribute(attr.name)
                storage.save('localStorage')
              })),
              (store.getAll = withIEStorage(function (storage) {
                for (
                  var attributes =
                      storage.XMLDocument.documentElement.attributes,
                    ret = {},
                    i = 0,
                    attr;
                  (attr = attributes[i]);
                  ++i
                ) {
                  var key = ieKeyFix(attr.name)
                  ret[attr.name] = store.deserialize(storage.getAttribute(key))
                }
                return ret
              }))
          }
          try {
            store.set(namespace, namespace),
              store.get(namespace) != namespace && (store.disabled = !0),
              store.remove(namespace)
          } catch (e) {
            store.disabled = !0
          }
          ;(store.enabled = !store.disabled), (module.exports = store)
        },
        { json: 56 },
      ],
      64: [
        function (require, module, exports) {
          module.exports = function (a, b) {
            var fn = function () {}
            ;(fn.prototype = b.prototype),
              (a.prototype = new fn()),
              (a.prototype.constructor = a)
          }
        },
        {},
      ],
      16: [
        function (require, module, exports) {
          var isEmpty = require('is-empty')
          try {
            var typeOf = require('type')
          } catch (e) {
            var typeOf = require('component-type')
          }
          for (
            var types = [
                'arguments',
                'array',
                'boolean',
                'date',
                'element',
                'function',
                'null',
                'number',
                'object',
                'regexp',
                'string',
                'undefined',
              ],
              i = 0,
              type;
            (type = types[i]);
            i++
          )
            exports[type] = generate(type)
          function generate(type) {
            return function (value) {
              return type === typeOf(value)
            }
          }
          ;(exports.fn = exports.function),
            (exports.empty = isEmpty),
            (exports.nan = function (val) {
              return exports.number(val) && val != val
            })
        },
        { 'is-empty': 46, type: 43, 'component-type': 43 },
      ],
      17: [
        function (require, module, exports) {
          module.exports = function isMeta(e) {
            if (e.metaKey || e.altKey || e.ctrlKey || e.shiftKey) return !0
            var which = e.which,
              button = e.button
            return which || void 0 === button
              ? 2 === which
              : 1 & !button && 2 & !button && 4 & button
          }
        },
        {},
      ],
      18: [
        function (require, module, exports) {
          var has = Object.prototype.hasOwnProperty
          ;(exports.keys =
            Object.keys ||
            function (obj) {
              var keys = []
              for (var key in obj) has.call(obj, key) && keys.push(key)
              return keys
            }),
            (exports.values = function (obj) {
              var vals = []
              for (var key in obj) has.call(obj, key) && vals.push(obj[key])
              return vals
            }),
            (exports.merge = function (a, b) {
              for (var key in b) has.call(b, key) && (a[key] = b[key])
              return a
            }),
            (exports.length = function (obj) {
              return exports.keys(obj).length
            }),
            (exports.isEmpty = function (obj) {
              return 0 == exports.length(obj)
            })
        },
        {},
      ],
      20: [
        function (require, module, exports) {
          var debug = require('debug')('analytics.js:normalize'),
            defaults = require('defaults'),
            each = require('each'),
            includes = require('includes'),
            is = require('is'),
            map = require('component/map'),
            has = Object.prototype.hasOwnProperty
          module.exports = normalize
          var toplevel = ['integrations', 'anonymousId', 'timestamp', 'context']
          function normalize(msg, list) {
            var lower = map(list, function (s) {
                return s.toLowerCase()
              }),
              opts = msg.options || {},
              integrations = opts.integrations || {},
              providers = opts.providers || {},
              context = opts.context || {},
              ret = {}
            return (
              debug('<-', msg),
              each(opts, function (key, value) {
                integration(key) &&
                  (has.call(integrations, key) || (integrations[key] = value),
                  delete opts[key])
              }),
              delete opts.providers,
              each(providers, function (key, value) {
                integration(key) &&
                  (is.object(integrations[key]) ||
                    (has.call(integrations, key) &&
                      'boolean' == typeof providers[key]) ||
                    (integrations[key] = value))
              }),
              each(opts, function (key) {
                includes(key, toplevel)
                  ? (ret[key] = opts[key])
                  : (context[key] = opts[key])
              }),
              delete msg.options,
              (ret.integrations = integrations),
              (ret.context = context),
              (ret = defaults(ret, msg)),
              debug('->', ret),
              ret
            )
            function integration(name) {
              return !(
                !includes(name, list) &&
                'all' !== name.toLowerCase() &&
                !includes(name.toLowerCase(), lower)
              )
            }
          }
        },
        {
          debug: 13,
          defaults: 14,
          each: 4,
          includes: 67,
          is: 16,
          'component/map': 68,
        },
      ],
      67: [
        function (require, module, exports) {
          'use strict'
          var each
          try {
            each = require('@ndhoule/each')
          } catch (e) {
            each = require('each')
          }
          var strIndexOf = String.prototype.indexOf,
            sameValueZero = function sameValueZero(value1, value2) {
              return value1 === value2
                ? 0 !== value1 || 1 / value1 == 1 / value2
                : value1 != value1 && value2 != value2
            },
            includes = function includes(searchElement, collection) {
              var found = !1
              return 'string' == typeof collection
                ? -1 !== strIndexOf.call(collection, searchElement)
                : (each(function (value) {
                    if (sameValueZero(value, searchElement))
                      return (found = !0), !1
                  }, collection),
                  found)
            }
          module.exports = includes
        },
        { each: 69 },
      ],
      69: [
        function (require, module, exports) {
          'use strict'
          var keys
          try {
            keys = require('@ndhoule/keys')
          } catch (e) {
            keys = require('keys')
          }
          var objToString = Object.prototype.toString,
            isNumber = function isNumber(val) {
              var type = typeof val
              return (
                'number' === type ||
                ('object' === type &&
                  '[object Number]' === objToString.call(val))
              )
            },
            isArray =
              'function' == typeof Array.isArray
                ? Array.isArray
                : function isArray(val) {
                    return '[object Array]' === objToString.call(val)
                  },
            isArrayLike = function isArrayLike(val) {
              return (
                null != val &&
                (isArray(val) || ('function' !== val && isNumber(val.length)))
              )
            },
            arrayEach = function arrayEach(iterator, array) {
              for (
                var i = 0;
                i < array.length && !1 !== iterator(array[i], i, array);
                i += 1
              );
            },
            baseEach = function baseEach(iterator, object) {
              for (
                var ks = keys(object), i = 0;
                i < ks.length && !1 !== iterator(object[ks[i]], ks[i], object);
                i += 1
              );
            },
            each = function each(iterator, collection) {
              return (isArrayLike(collection) ? arrayEach : baseEach).call(
                this,
                iterator,
                collection
              )
            }
          module.exports = each
        },
        { keys: 70 },
      ],
      70: [
        function (require, module, exports) {
          'use strict'
          var strCharAt = String.prototype.charAt,
            charAt = function (str, index) {
              return strCharAt.call(str, index)
            },
            hop = Object.prototype.hasOwnProperty,
            toStr = Object.prototype.toString,
            has = function has(context, prop) {
              return hop.call(context, prop)
            },
            isString = function isString(val) {
              return '[object String]' === toStr.call(val)
            },
            isArrayLike = function isArrayLike(val) {
              return (
                null != val &&
                'function' != typeof val &&
                'number' == typeof val.length
              )
            },
            indexKeys = function indexKeys(target, pred) {
              pred = pred || has
              for (
                var results = [], i = 0, len = target.length;
                i < len;
                i += 1
              )
                pred(target, i) && results.push(String(i))
              return results
            },
            objectKeys = function objectKeys(target, pred) {
              pred = pred || has
              var results = []
              for (var key in target)
                pred(target, key) && results.push(String(key))
              return results
            }
          module.exports = function keys(source) {
            return null == source
              ? []
              : isString(source)
              ? indexKeys(source, charAt)
              : isArrayLike(source)
              ? indexKeys(source, has)
              : objectKeys(source)
          }
        },
        {},
      ],
      68: [
        function (require, module, exports) {
          var toFunction = require('to-function')
          module.exports = function (arr, fn) {
            var ret = []
            fn = toFunction(fn)
            for (var i = 0; i < arr.length; ++i) ret.push(fn(arr[i], i))
            return ret
          }
        },
        { 'to-function': 71 },
      ],
      71: [
        function (require, module, exports) {
          var expr
          try {
            expr = require('props')
          } catch (e) {
            expr = require('component-props')
          }
          function toFunction(obj) {
            switch ({}.toString.call(obj)) {
              case '[object Object]':
                return objectToFunction(obj)
              case '[object Function]':
                return obj
              case '[object String]':
                return stringToFunction(obj)
              case '[object RegExp]':
                return regexpToFunction(obj)
              default:
                return defaultToFunction(obj)
            }
          }
          function defaultToFunction(val) {
            return function (obj) {
              return val === obj
            }
          }
          function regexpToFunction(re) {
            return function (obj) {
              return re.test(obj)
            }
          }
          function stringToFunction(str) {
            return /^ *\W+/.test(str)
              ? new Function('_', 'return _ ' + str)
              : new Function('_', 'return ' + get(str))
          }
          function objectToFunction(obj) {
            var match = {}
            for (var key in obj)
              match[key] =
                'string' == typeof obj[key]
                  ? defaultToFunction(obj[key])
                  : toFunction(obj[key])
            return function (val) {
              if ('object' != typeof val) return !1
              for (var key in match) {
                if (!(key in val)) return !1
                if (!match[key](val[key])) return !1
              }
              return !0
            }
          }
          function get(str) {
            var props = expr(str),
              val,
              i,
              prop
            if (!props.length) return '_.' + str
            for (i = 0; i < props.length; i++)
              str = stripNested(
                (prop = props[i]),
                str,
                (val =
                  "('function' == typeof " +
                  (val = '_.' + prop) +
                  ' ? ' +
                  val +
                  '() : ' +
                  val +
                  ')')
              )
            return str
          }
          function stripNested(prop, str, val) {
            return str.replace(
              new RegExp('(\\.)?' + prop, 'g'),
              function ($0, $1) {
                return $1 ? $0 : val
              }
            )
          }
          module.exports = toFunction
        },
        { props: 72, 'component-props': 72 },
      ],
      72: [
        function (require, module, exports) {
          var globals = /\b(this|Array|Date|Object|Math|JSON)\b/g
          function props(str) {
            return (
              str
                .replace(/\.\w+|\w+ *\(|"[^"]*"|'[^']*'|\/([^/]+)\//g, '')
                .replace(globals, '')
                .match(/[$a-zA-Z_]\w*/g) || []
            )
          }
          function map(str, props, fn) {
            var re = /\.\w+|\w+ *\(|"[^"]*"|'[^']*'|\/([^/]+)\/|[a-zA-Z_]\w*/g
            return str.replace(re, function (_) {
              return '(' == _[_.length - 1]
                ? fn(_)
                : ~props.indexOf(_)
                ? fn(_)
                : _
            })
          }
          function unique(arr) {
            for (var ret = [], i = 0; i < arr.length; i++)
              ~ret.indexOf(arr[i]) || ret.push(arr[i])
            return ret
          }
          function prefixed(str) {
            return function (_) {
              return str + _
            }
          }
          module.exports = function (str, fn) {
            var p = unique(props(str))
            return (
              fn && 'string' == typeof fn && (fn = prefixed(fn)),
              fn ? map(str, p, fn) : p
            )
          }
        },
        {},
      ],
      21: [
        function (require, module, exports) {
          ;(exports.bind = function (el, type, fn, capture) {
            return (
              el.addEventListener
                ? el.addEventListener(type, fn, capture || !1)
                : el.attachEvent('on' + type, fn),
              fn
            )
          }),
            (exports.unbind = function (el, type, fn, capture) {
              return (
                el.removeEventListener
                  ? el.removeEventListener(type, fn, capture || !1)
                  : el.detachEvent('on' + type, fn),
                fn
              )
            })
        },
        {},
      ],
      22: [
        function (require, module, exports) {
          var canonical = require('canonical'),
            includes = require('includes'),
            url = require('url')
          function pageDefaults() {
            return {
              path: canonicalPath(),
              referrer: document.referrer,
              search: location.search,
              title: document.title,
              url: canonicalUrl(location.search),
            }
          }
          function canonicalPath() {
            var canon = canonical(),
              parsed
            return canon ? url.parse(canon).pathname : window.location.pathname
          }
          function canonicalUrl(search) {
            var canon = canonical()
            if (canon) return includes('?', canon) ? canon : canon + search
            var url = window.location.href,
              i = url.indexOf('#')
            return -1 === i ? url : url.slice(0, i)
          }
          module.exports = pageDefaults
        },
        { canonical: 73, includes: 67, url: 74 },
      ],
      73: [
        function (require, module, exports) {
          module.exports = function canonical() {
            for (
              var tags = document.getElementsByTagName('link'), i = 0, tag;
              (tag = tags[i]);
              i++
            )
              if ('canonical' == tag.getAttribute('rel'))
                return tag.getAttribute('href')
          }
        },
        {},
      ],
      74: [
        function (require, module, exports) {
          function port(protocol) {
            switch (protocol) {
              case 'http:':
                return 80
              case 'https:':
                return 443
              default:
                return location.port
            }
          }
          ;(exports.parse = function (url) {
            var a = document.createElement('a')
            return (
              (a.href = url),
              {
                href: a.href,
                host: a.host || location.host,
                port:
                  '0' === a.port || '' === a.port ? port(a.protocol) : a.port,
                hash: a.hash,
                hostname: a.hostname || location.hostname,
                pathname:
                  '/' != a.pathname.charAt(0) ? '/' + a.pathname : a.pathname,
                protocol:
                  a.protocol && ':' != a.protocol
                    ? a.protocol
                    : location.protocol,
                search: a.search,
                query: a.search.slice(1),
              }
            )
          }),
            (exports.isAbsolute = function (url) {
              return 0 == url.indexOf('//') || !!~url.indexOf('://')
            }),
            (exports.isRelative = function (url) {
              return !exports.isAbsolute(url)
            }),
            (exports.isCrossDomain = function (url) {
              url = exports.parse(url)
              var location = exports.parse(window.location.href)
              return (
                url.hostname !== location.hostname ||
                url.port !== location.port ||
                url.protocol !== location.protocol
              )
            })
        },
        {},
      ],
      23: [
        function (require, module, exports) {
          'use strict'
          var objToString = Object.prototype.toString,
            existy = function (val) {
              return null != val
            },
            isArray = function (val) {
              return '[object Array]' === objToString.call(val)
            },
            isString = function (val) {
              return (
                'string' == typeof val ||
                '[object String]' === objToString.call(val)
              )
            },
            isObject = function (val) {
              return null != val && 'object' == typeof val
            },
            pick = function pick(props, object) {
              if (!existy(object) || !isObject(object)) return {}
              isString(props) && (props = [props]),
                isArray(props) || (props = [])
              for (var result = {}, i = 0; i < props.length; i += 1)
                isString(props[i]) &&
                  props[i] in object &&
                  (result[props[i]] = object[props[i]])
              return result
            }
          module.exports = pick
        },
        {},
      ],
      24: [
        function (require, module, exports) {
          module.exports = function (e) {
            return (e = e || window.event).preventDefault
              ? e.preventDefault()
              : (e.returnValue = !1)
          }
        },
        {},
      ],
      25: [
        function (require, module, exports) {
          var encode = encodeURIComponent,
            decode = decodeURIComponent,
            trim = require('trim'),
            type = require('type')
          ;(exports.parse = function (str) {
            if ('string' != typeof str) return {}
            if ('' == (str = trim(str))) return {}
            '?' == str.charAt(0) && (str = str.slice(1))
            for (
              var obj = {}, pairs = str.split('&'), i = 0;
              i < pairs.length;
              i++
            ) {
              var parts = pairs[i].split('='),
                key = decode(parts[0]),
                m
              ;(m = /(\w+)\[(\d+)\]/.exec(key))
                ? ((obj[m[1]] = obj[m[1]] || []),
                  (obj[m[1]][m[2]] = decode(parts[1])))
                : (obj[parts[0]] = null == parts[1] ? '' : decode(parts[1]))
            }
            return obj
          }),
            (exports.stringify = function (obj) {
              if (!obj) return ''
              var pairs = []
              for (var key in obj) {
                var value = obj[key]
                if ('array' != type(value))
                  pairs.push(encode(key) + '=' + encode(obj[key]))
                else
                  for (var i = 0; i < value.length; ++i)
                    pairs.push(
                      encode(key + '[' + i + ']') + '=' + encode(value[i])
                    )
              }
              return pairs.join('&')
            })
        },
        { trim: 51, type: 43 },
      ],
      27: [
        function (require, module, exports) {
          var Entity = require('./entity'),
            bind = require('bind'),
            cookie = require('./cookie'),
            debug = require('debug')('analytics:user'),
            inherit = require('inherit'),
            rawCookie = require('cookie'),
            uuid = require('uuid')
          function User(options) {
            ;(this.defaults = User.defaults),
              (this.debug = debug),
              Entity.call(this, options)
          }
          ;(User.defaults = {
            persist: !0,
            cookie: { key: 'ajs_user_id', oldKey: 'ajs_user' },
            localStorage: { key: 'ajs_user_traits' },
          }),
            inherit(User, Entity),
            (User.prototype.id = function (id) {
              var prev = this._getId(),
                ret = Entity.prototype.id.apply(this, arguments)
              return null == prev
                ? ret
                : (prev != id && id && this.anonymousId(null), ret)
            }),
            (User.prototype.anonymousId = function (anonymousId) {
              var store = this.storage()
              return arguments.length
                ? (store.set('ajs_anonymous_id', anonymousId), this)
                : (anonymousId = store.get('ajs_anonymous_id'))
                ? anonymousId
                : (anonymousId = rawCookie('_sio'))
                ? ((anonymousId = anonymousId.split('----')[0]),
                  store.set('ajs_anonymous_id', anonymousId),
                  store.remove('_sio'),
                  anonymousId)
                : ((anonymousId = uuid()),
                  store.set('ajs_anonymous_id', anonymousId),
                  store.get('ajs_anonymous_id'))
            }),
            (User.prototype.logout = function () {
              Entity.prototype.logout.call(this), this.anonymousId(null)
            }),
            (User.prototype.load = function () {
              this._loadOldCookie() || Entity.prototype.load.call(this)
            }),
            (User.prototype._loadOldCookie = function () {
              var user = cookie.get(this._options.cookie.oldKey)
              return (
                !!user &&
                (this.id(user.id),
                this.traits(user.traits),
                cookie.remove(this._options.cookie.oldKey),
                !0)
              )
            }),
            (module.exports = bind.all(new User())),
            (module.exports.User = User)
        },
        {
          './entity': 63,
          bind: 9,
          './cookie': 12,
          debug: 13,
          inherit: 64,
          cookie: 55,
          uuid: 75,
        },
      ],
      75: [
        function (require, module, exports) {
          module.exports = function uuid(a) {
            return a
              ? (a ^ ((16 * Math.random()) >> (a / 4))).toString(16)
              : ([1e7] + -1e3 + -4e3 + -8e3 + -1e11).replace(/[018]/g, uuid)
          }
        },
        {},
      ],
      3: [
        function (require, module, exports) {
          'use strict'
          module.exports = {
            'google-analytics': require('analytics.js-integration-google-analytics'),
            mixpanel: require('analytics.js-integration-mixpanel'),
            segmentio: require('analytics.js-integration-segmentio'),
            sumome: require('UseFedora/fedora-analytics.js-integration-sumome'),
          }
        },
        {
          'analytics.js-integration-google-analytics': 108,
          'analytics.js-integration-mixpanel': 126,
          'analytics.js-integration-segmentio': 145,
          'UseFedora/fedora-analytics.js-integration-sumome': 162,
        },
      ],
      163: [
        function (require, module, exports) {
          var bind = require('bind'),
            clone = require('clone'),
            debug = require('debug'),
            defaults = require('defaults'),
            extend = require('extend'),
            slug = require('slug'),
            protos = require('./protos'),
            statics = require('./statics')
          function createIntegration(name) {
            function Integration(options) {
              if (options && options.addIntegration)
                return options.addIntegration(Integration)
              ;(this.debug = debug('analytics:integration:' + slug(name))),
                (this.options = defaults(clone(options) || {}, this.defaults)),
                (this._queue = []),
                this.once('ready', bind(this, this.flush)),
                Integration.emit('construct', this),
                (this.ready = bind(this, this.ready)),
                this._wrapInitialize(),
                this._wrapPage(),
                this._wrapTrack()
            }
            return (
              (Integration.prototype.defaults = {}),
              (Integration.prototype.globals = []),
              (Integration.prototype.templates = {}),
              (Integration.prototype.name = name),
              extend(Integration, statics),
              extend(Integration.prototype, protos),
              Integration
            )
          }
          module.exports = createIntegration
        },
        {
          bind: 166,
          clone: 11,
          debug: 167,
          defaults: 14,
          extend: 168,
          slug: 169,
          './protos': 170,
          './statics': 171,
        },
      ],
      166: [
        function (require, module, exports) {
          var bind = require('bind'),
            bindAll = require('bind-all')
          function bindMethods(obj, methods) {
            methods = [].slice.call(arguments, 1)
            for (var i = 0, method; (method = methods[i]); i++)
              obj[method] = bind(obj, obj[method])
            return obj
          }
          ;(module.exports = exports = bind),
            (exports.all = bindAll),
            (exports.methods = bindMethods)
        },
        { bind: 52, 'bind-all': 53 },
      ],
      167: [
        function (require, module, exports) {
          'undefined' == typeof window
            ? (module.exports = require('./lib/debug'))
            : (module.exports = require('./debug'))
        },
        { './lib/debug': 172, './debug': 173 },
      ],
      172: [
        function (require, module, exports) {
          var tty = require('tty')
          module.exports = debug
          var names = [],
            skips = []
          ;(process.env.DEBUG || '').split(/[\s,]+/).forEach(function (name) {
            '-' === (name = name.replace('*', '.*?'))[0]
              ? skips.push(new RegExp('^' + name.substr(1) + '$'))
              : names.push(new RegExp('^' + name + '$'))
          })
          var colors = [6, 2, 3, 4, 5, 1],
            prev = {},
            prevColor = 0,
            isatty = tty.isatty(2)
          function color() {
            return colors[prevColor++ % colors.length]
          }
          function humanize(ms) {
            var sec = 1e3,
              min = 6e4,
              hour = 36e5
            return ms >= 36e5
              ? (ms / 36e5).toFixed(1) + 'h'
              : ms >= 6e4
              ? (ms / 6e4).toFixed(1) + 'm'
              : ms >= 1e3
              ? ((ms / 1e3) | 0) + 's'
              : ms + 'ms'
          }
          function debug(name) {
            function disabled() {}
            disabled.enabled = !1
            var match = skips.some(function (re) {
              return re.test(name)
            })
            if (match) return disabled
            if (
              !(match = names.some(function (re) {
                return re.test(name)
              }))
            )
              return disabled
            var c = color()
            function colored(fmt) {
              fmt = coerce(fmt)
              var curr = new Date(),
                ms = curr - (prev[name] || curr)
              ;(prev[name] = curr),
                (fmt =
                  '  [9' +
                  c +
                  'm' +
                  name +
                  ' [3' +
                  c +
                  'm[90m' +
                  fmt +
                  '[3' +
                  c +
                  'm +' +
                  humanize(ms) +
                  '[0m'),
                console.error.apply(this, arguments)
            }
            function plain(fmt) {
              ;(fmt = coerce(fmt)),
                (fmt = new Date().toUTCString() + ' ' + name + ' ' + fmt),
                console.error.apply(this, arguments)
            }
            return (
              (colored.enabled = plain.enabled = !0),
              isatty || process.env.DEBUG_COLORS ? colored : plain
            )
          }
          function coerce(val) {
            return val instanceof Error ? val.stack || val.message : val
          }
        },
        {},
      ],
      173: [
        function (require, module, exports) {
          function debug(name) {
            return debug.enabled(name)
              ? function (fmt) {
                  fmt = coerce(fmt)
                  var curr = new Date(),
                    ms = curr - (debug[name] || curr)
                  ;(debug[name] = curr),
                    (fmt = name + ' ' + fmt + ' +' + debug.humanize(ms)),
                    window.console &&
                      console.log &&
                      Function.prototype.apply.call(
                        console.log,
                        console,
                        arguments
                      )
                }
              : function () {}
          }
          function coerce(val) {
            return val instanceof Error ? val.stack || val.message : val
          }
          ;(module.exports = debug),
            (debug.names = []),
            (debug.skips = []),
            (debug.enable = function (name) {
              try {
                localStorage.debug = name
              } catch (e) {}
              for (
                var split = (name || '').split(/[\s,]+/),
                  len = split.length,
                  i = 0;
                i < len;
                i++
              )
                '-' === (name = split[i].replace('*', '.*?'))[0]
                  ? debug.skips.push(new RegExp('^' + name.substr(1) + '$'))
                  : debug.names.push(new RegExp('^' + name + '$'))
            }),
            (debug.disable = function () {
              debug.enable('')
            }),
            (debug.humanize = function (ms) {
              var sec = 1e3,
                min = 6e4,
                hour = 36e5
              return ms >= 36e5
                ? (ms / 36e5).toFixed(1) + 'h'
                : ms >= 6e4
                ? (ms / 6e4).toFixed(1) + 'm'
                : ms >= 1e3
                ? ((ms / 1e3) | 0) + 's'
                : ms + 'ms'
            }),
            (debug.enabled = function (name) {
              for (var i = 0, len = debug.skips.length; i < len; i++)
                if (debug.skips[i].test(name)) return !1
              for (var i = 0, len = debug.names.length; i < len; i++)
                if (debug.names[i].test(name)) return !0
              return !1
            })
          try {
            window.localStorage && debug.enable(localStorage.debug)
          } catch (e) {}
        },
        {},
      ],
      168: [
        function (require, module, exports) {
          module.exports = function extend(object) {
            for (
              var args = Array.prototype.slice.call(arguments, 1),
                i = 0,
                source;
              (source = args[i]);
              i++
            )
              if (source)
                for (var property in source) object[property] = source[property]
            return object
          }
        },
        {},
      ],
      169: [
        function (require, module, exports) {
          module.exports = function (str, options) {
            return (
              options || (options = {}),
              str
                .toLowerCase()
                .replace(options.replace || /[^a-z0-9]/g, ' ')
                .replace(/^ +| +$/g, '')
                .replace(/ +/g, options.separator || '-')
            )
          }
        },
        {},
      ],
      170: [
        function (require, module, exports) {
          var Emitter = require('emitter'),
            after = require('after'),
            each = require('each'),
            events = require('analytics-events'),
            fmt = require('fmt'),
            foldl = require('foldl'),
            loadIframe = require('load-iframe'),
            loadScript = require('load-script'),
            normalize = require('to-no-case'),
            nextTick = require('next-tick'),
            type = require('type')
          function noop() {}
          var has = Object.prototype.hasOwnProperty,
            onerror = window.onerror,
            onload = null,
            setInterval = window.setInterval,
            setTimeout = window.setTimeout
          function loadImage(attrs, fn) {
            fn = fn || function () {}
            var img = new Image()
            return (
              (img.onerror = error(fn, 'failed to load pixel', img)),
              (img.onload = function () {
                fn()
              }),
              (img.src = attrs.src),
              (img.width = 1),
              (img.height = 1),
              img
            )
          }
          function error(fn, message, img) {
            return function (e) {
              e = e || window.event
              var err = new Error(message)
              ;(err.event = e), (err.source = img), fn(err)
            }
          }
          function render(template, locals) {
            return foldl(
              function (attrs, val, key) {
                return (
                  (attrs[key] = val.replace(
                    /\{\{\ *(\w+)\ *\}\}/g,
                    function (_, $1) {
                      return locals[$1]
                    }
                  )),
                  attrs
                )
              },
              {},
              template.attrs
            )
          }
          Emitter(exports),
            (exports.initialize = function () {
              var ready = this.ready
              nextTick(ready)
            }),
            (exports.loaded = function () {
              return !1
            }),
            (exports.page = function (page) {}),
            (exports.track = function (track) {}),
            (exports.map = function (events, event) {
              var normalizedEvent = normalize(event)
              return foldl(
                function (matchingEvents, val, key, events) {
                  if ('array' === type(events)) {
                    if (!val.key) return matchingEvents
                    ;(key = val.key), (val = val.value)
                  }
                  return (
                    normalize(key) === normalizedEvent &&
                      matchingEvents.push(val),
                    matchingEvents
                  )
                },
                [],
                events
              )
            }),
            (exports.invoke = function (method) {
              if (this[method]) {
                var args = Array.prototype.slice.call(arguments, 1),
                  ret
                if (!this._ready) return this.queue(method, args)
                try {
                  this.debug('%s with %o', method, args),
                    (ret = this[method].apply(this, args))
                } catch (e) {
                  this.debug('error %o calling %s with %o', e, method, args)
                }
                return ret
              }
            }),
            (exports.queue = function (method, args) {
              if (
                'page' === method &&
                this._assumesPageview &&
                !this._initialized
              )
                return this.page.apply(this, args)
              this._queue.push({ method: method, args: args })
            }),
            (exports.flush = function () {
              this._ready = !0
              var self = this
              each(this._queue, function (call) {
                self[call.method].apply(self, call.args)
              }),
                (this._queue.length = 0)
            }),
            (exports.reset = function () {
              for (var i = 0; i < this.globals.length; i++)
                window[this.globals[i]] = void 0
              ;(window.setTimeout = setTimeout),
                (window.setInterval = setInterval),
                (window.onerror = onerror),
                (window.onload = null)
            }),
            (exports.load = function (name, locals, callback) {
              'function' == typeof name &&
                ((callback = name), (locals = null), (name = null)),
                name &&
                  'object' == typeof name &&
                  ((callback = locals), (locals = name), (name = null)),
                'function' == typeof locals &&
                  ((callback = locals), (locals = null)),
                (name = name || 'library'),
                (locals = locals || {}),
                (locals = this.locals(locals))
              var template = this.templates[name]
              if (!template)
                throw new Error(fmt('template "%s" not defined.', name))
              var attrs = render(template, locals)
              callback = callback || noop
              var self = this,
                el
              switch (template.type) {
                case 'img':
                  ;(attrs.width = 1),
                    (attrs.height = 1),
                    (el = loadImage(attrs, callback))
                  break
                case 'script':
                  ;(el = loadScript(attrs, function (err) {
                    if (!err) return callback()
                    self.debug('error loading "%s" error="%s"', self.name, err)
                  })),
                    delete attrs.src,
                    each(attrs, function (key, val) {
                      el.setAttribute(key, val)
                    })
                  break
                case 'iframe':
                  el = loadIframe(attrs, callback)
              }
              return el
            }),
            (exports.locals = function (locals) {
              locals = locals || {}
              var cache = Math.floor(new Date().getTime() / 36e5)
              return (
                locals.hasOwnProperty('cache') || (locals.cache = cache),
                each(this.options, function (key, val) {
                  locals.hasOwnProperty(key) || (locals[key] = val)
                }),
                locals
              )
            }),
            (exports.ready = function () {
              this.emit('ready')
            }),
            (exports._wrapInitialize = function () {
              var initialize = this.initialize
              ;(this.initialize = function () {
                this.debug('initialize'), (this._initialized = !0)
                var ret = initialize.apply(this, arguments)
                return this.emit('initialize'), ret
              }),
                this._assumesPageview &&
                  (this.initialize = after(2, this.initialize))
            }),
            (exports._wrapPage = function () {
              var page = this.page
              this.page = function () {
                return this._assumesPageview && !this._initialized
                  ? this.initialize.apply(this, arguments)
                  : page.apply(this, arguments)
              }
            }),
            (exports._wrapTrack = function () {
              var t = this.track
              this.track = function (track) {
                var event = track.event(),
                  called,
                  ret
                for (var method in events)
                  if (has.call(events, method)) {
                    var regexp = events[method]
                    if (!this[method]) continue
                    if (!regexp.test(event)) continue
                    ;(ret = this[method].apply(this, arguments)), (called = !0)
                    break
                  }
                return called || (ret = t.apply(this, arguments)), ret
              }
            })
        },
        {
          emitter: 6,
          after: 8,
          each: 174,
          'analytics-events': 175,
          fmt: 176,
          foldl: 177,
          'load-iframe': 178,
          'load-script': 179,
          'to-no-case': 180,
          'next-tick': 54,
          type: 181,
        },
      ],
      174: [
        function (require, module, exports) {
          try {
            var type = require('type')
          } catch (err) {
            var type = require('component-type')
          }
          var toFunction = require('to-function'),
            has = Object.prototype.hasOwnProperty
          function string(obj, fn, ctx) {
            for (var i = 0; i < obj.length; ++i) fn.call(ctx, obj.charAt(i), i)
          }
          function object(obj, fn, ctx) {
            for (var key in obj)
              has.call(obj, key) && fn.call(ctx, key, obj[key])
          }
          function array(obj, fn, ctx) {
            for (var i = 0; i < obj.length; ++i) fn.call(ctx, obj[i], i)
          }
          module.exports = function (obj, fn, ctx) {
            switch (((fn = toFunction(fn)), (ctx = ctx || this), type(obj))) {
              case 'array':
                return array(obj, fn, ctx)
              case 'object':
                return 'number' == typeof obj.length
                  ? array(obj, fn, ctx)
                  : object(obj, fn, ctx)
              case 'string':
                return string(obj, fn, ctx)
            }
          }
        },
        { type: 181, 'component-type': 181, 'to-function': 71 },
      ],
      181: [
        function (require, module, exports) {
          var toString = Object.prototype.toString
          module.exports = function (val) {
            switch (toString.call(val)) {
              case '[object Function]':
                return 'function'
              case '[object Date]':
                return 'date'
              case '[object RegExp]':
                return 'regexp'
              case '[object Arguments]':
                return 'arguments'
              case '[object Array]':
                return 'array'
              case '[object String]':
                return 'string'
            }
            return null === val
              ? 'null'
              : void 0 === val
              ? 'undefined'
              : val && 1 === val.nodeType
              ? 'element'
              : val === Object(val)
              ? 'object'
              : typeof val
          }
        },
        {},
      ],
      175: [
        function (require, module, exports) {
          module.exports = {
            removedProduct: /^[ _]?removed[ _]?product[ _]?$/i,
            viewedProduct: /^[ _]?viewed[ _]?product[ _]?$/i,
            viewedProductCategory:
              /^[ _]?viewed[ _]?product[ _]?category[ _]?$/i,
            addedProduct: /^[ _]?added[ _]?product[ _]?$/i,
            completedOrder: /^[ _]?completed[ _]?order[ _]?$/i,
            startedOrder: /^[ _]?started[ _]?order[ _]?$/i,
            updatedOrder: /^[ _]?updated[ _]?order[ _]?$/i,
            refundedOrder: /^[ _]?refunded?[ _]?order[ _]?$/i,
            viewedProductDetails:
              /^[ _]?viewed[ _]?product[ _]?details?[ _]?$/i,
            clickedProduct: /^[ _]?clicked[ _]?product[ _]?$/i,
            viewedPromotion: /^[ _]?viewed[ _]?promotion?[ _]?$/i,
            clickedPromotion: /^[ _]?clicked[ _]?promotion?[ _]?$/i,
            viewedCheckoutStep: /^[ _]?viewed[ _]?checkout[ _]?step[ _]?$/i,
            completedCheckoutStep:
              /^[ _]?completed[ _]?checkout[ _]?step[ _]?$/i,
          }
        },
        {},
      ],
      176: [
        function (require, module, exports) {
          var toString = window.JSON
            ? JSON.stringify
            : function (_) {
                return String(_)
              }
          function fmt(str) {
            var args = [].slice.call(arguments, 1),
              j = 0
            return str.replace(/%([a-z])/gi, function (_, f) {
              return fmt[f] ? fmt[f](args[j++]) : _ + f
            })
          }
          ;(module.exports = fmt),
            (fmt.o = toString),
            (fmt.s = String),
            (fmt.d = parseInt)
        },
        {},
      ],
      177: [
        function (require, module, exports) {
          'use strict'
          var each
          try {
            each = require('@ndhoule/each')
          } catch (e) {
            each = require('each')
          }
          var foldl = function foldl(iterator, accumulator, collection) {
            if ('function' != typeof iterator)
              throw new TypeError(
                'Expected a function but received a ' + typeof iterator
              )
            return (
              each(function (val, i, collection) {
                accumulator = iterator(accumulator, val, i, collection)
              }, collection),
              accumulator
            )
          }
          module.exports = foldl
        },
        { each: 69 },
      ],
      178: [
        function (require, module, exports) {
          var onload = require('script-onload'),
            tick = require('next-tick'),
            type = require('type')
          module.exports = function loadIframe(options, fn) {
            if (!options) throw new Error('Cant load nothing...')
            'string' == type(options) && (options = { src: options })
            var https =
              'https:' === document.location.protocol ||
              'chrome-extension:' === document.location.protocol
            options.src &&
              0 === options.src.indexOf('//') &&
              (options.src = https
                ? 'https:' + options.src
                : 'http:' + options.src),
              https && options.https
                ? (options.src = options.https)
                : !https && options.http && (options.src = options.http)
            var iframe = document.createElement('iframe')
            return (
              (iframe.src = options.src),
              (iframe.width = options.width || 1),
              (iframe.height = options.height || 1),
              (iframe.style.display = 'none'),
              'function' == type(fn) && onload(iframe, fn),
              tick(function () {
                var firstScript = document.getElementsByTagName('script')[0]
                firstScript.parentNode.insertBefore(iframe, firstScript)
              }),
              iframe
            )
          }
        },
        { 'script-onload': 182, 'next-tick': 54, type: 43 },
      ],
      182: [
        function (require, module, exports) {
          function add(el, fn) {
            el.addEventListener(
              'load',
              function (_, e) {
                fn(null, e)
              },
              !1
            ),
              el.addEventListener(
                'error',
                function (e) {
                  var err = new Error('script error "' + el.src + '"')
                  ;(err.event = e), fn(err)
                },
                !1
              )
          }
          function attach(el, fn) {
            el.attachEvent('onreadystatechange', function (e) {
              ;/complete|loaded/.test(el.readyState) && fn(null, e)
            }),
              el.attachEvent('onerror', function (e) {
                var err = new Error(
                  'failed to load the script "' + el.src + '"'
                )
                ;(err.event = e || window.event), fn(err)
              })
          }
          module.exports = function (el, fn) {
            return el.addEventListener ? add(el, fn) : attach(el, fn)
          }
        },
        {},
      ],
      179: [
        function (require, module, exports) {
          var onload = require('script-onload'),
            tick = require('next-tick'),
            type = require('type')
          module.exports = function loadScript(options, fn) {
            if (!options) throw new Error('Cant load nothing...')
            'string' == type(options) && (options = { src: options })
            var https =
              'https:' === document.location.protocol ||
              'chrome-extension:' === document.location.protocol
            options.src &&
              0 === options.src.indexOf('//') &&
              (options.src = https
                ? 'https:' + options.src
                : 'http:' + options.src),
              https && options.https
                ? (options.src = options.https)
                : !https && options.http && (options.src = options.http)
            var script = document.createElement('script')
            return (
              (script.type = 'text/javascript'),
              (script.async = !0),
              (script.src = options.src),
              'function' == type(fn) && onload(script, fn),
              tick(function () {
                var firstScript = document.getElementsByTagName('script')[0]
                firstScript.parentNode.insertBefore(script, firstScript)
              }),
              script
            )
          }
        },
        { 'script-onload': 182, 'next-tick': 54, type: 43 },
      ],
      180: [
        function (require, module, exports) {
          module.exports = toNoCase
          var hasSpace = /\s/,
            hasSeparator = /[\W_]/
          function toNoCase(string) {
            return hasSpace.test(string)
              ? string.toLowerCase()
              : hasSeparator.test(string)
              ? unseparate(string).toLowerCase()
              : uncamelize(string).toLowerCase()
          }
          var separatorSplitter = /[\W_]+(.|$)/g
          function unseparate(string) {
            return string.replace(separatorSplitter, function (m, next) {
              return next ? ' ' + next : ''
            })
          }
          var camelSplitter = /(.)([A-Z]+)/g
          function uncamelize(string) {
            return string.replace(
              camelSplitter,
              function (m, previous, uppers) {
                return previous + ' ' + uppers.toLowerCase().split('').join(' ')
              }
            )
          }
        },
        {},
      ],
      171: [
        function (require, module, exports) {
          var Emitter = require('emitter'),
            domify = require('domify'),
            each = require('each'),
            includes = require('includes')
          function objectify(str) {
            str = str.replace(' src="', ' data-src="')
            var el = domify(str),
              attrs = {}
            return (
              each(el.attributes, function (attr) {
                var name = 'data-src' === attr.name ? 'src' : attr.name
                includes(attr.name + '=', str) && (attrs[name] = attr.value)
              }),
              { type: el.tagName.toLowerCase(), attrs: attrs }
            )
          }
          Emitter(exports),
            (exports.option = function (key, value) {
              return (this.prototype.defaults[key] = value), this
            }),
            (exports.mapping = function (name) {
              return (
                this.option(name, []),
                (this.prototype[name] = function (str) {
                  return this.map(this.options[name], str)
                }),
                this
              )
            }),
            (exports.global = function (key) {
              return this.prototype.globals.push(key), this
            }),
            (exports.assumesPageview = function () {
              return (this.prototype._assumesPageview = !0), this
            }),
            (exports.readyOnLoad = function () {
              return (this.prototype._readyOnLoad = !0), this
            }),
            (exports.readyOnInitialize = function () {
              return (this.prototype._readyOnInitialize = !0), this
            }),
            (exports.tag = function (name, tag) {
              return (
                null == tag && ((tag = name), (name = 'library')),
                (this.prototype.templates[name] = objectify(tag)),
                this
              )
            })
        },
        { emitter: 6, domify: 183, each: 174, includes: 67 },
      ],
      183: [
        function (require, module, exports) {
          module.exports = parse
          var div = document.createElement('div')
          div.innerHTML =
            '  <link/><table></table><a href="/a">a</a><input type="checkbox"/>'
          var innerHTMLBug = !div.getElementsByTagName('link').length
          div = void 0
          var map = {
            legend: [1, '<fieldset>', '</fieldset>'],
            tr: [2, '<table><tbody>', '</tbody></table>'],
            col: [2, '<table><tbody></tbody><colgroup>', '</colgroup></table>'],
            _default: innerHTMLBug ? [1, 'X<div>', '</div>'] : [0, '', ''],
          }
          function parse(html, doc) {
            if ('string' != typeof html) throw new TypeError('String expected')
            doc || (doc = document)
            var m = /<([\w:]+)/.exec(html)
            if (!m) return doc.createTextNode(html)
            html = html.replace(/^\s+|\s+$/g, '')
            var tag = m[1],
              el
            if ('body' == tag)
              return (
                ((el = doc.createElement('html')).innerHTML = html),
                el.removeChild(el.lastChild)
              )
            var wrap = map[tag] || map._default,
              depth = wrap[0],
              prefix = wrap[1],
              suffix = wrap[2],
              el
            for (
              (el = doc.createElement('div')).innerHTML =
                prefix + html + suffix;
              depth--;

            )
              el = el.lastChild
            if (el.firstChild == el.lastChild)
              return el.removeChild(el.firstChild)
            for (var fragment = doc.createDocumentFragment(); el.firstChild; )
              fragment.appendChild(el.removeChild(el.firstChild))
            return fragment
          }
          ;(map.td = map.th =
            [3, '<table><tbody><tr>', '</tr></tbody></table>']),
            (map.option = map.optgroup =
              [1, '<select multiple="multiple">', '</select>']),
            (map.thead =
              map.tbody =
              map.colgroup =
              map.caption =
              map.tfoot =
                [1, '<table>', '</table>']),
            (map.polyline =
              map.ellipse =
              map.polygon =
              map.circle =
              map.text =
              map.line =
              map.path =
              map.rect =
              map.g =
                [
                  1,
                  '<svg xmlns="http://www.w3.org/2000/svg" version="1.1">',
                  '</svg>',
                ])
        },
        {},
      ],
      164: [
        function (require, module, exports) {
          var toSpace = require('to-space-case')
          function toSnakeCase(string) {
            return toSpace(string).replace(/\s/g, '_')
          }
          module.exports = toSnakeCase
        },
        { 'to-space-case': 184 },
      ],
      184: [
        function (require, module, exports) {
          var clean = require('to-no-case')
          function toSpaceCase(string) {
            return clean(string).replace(
              /[\W_]+(.|$)/g,
              function (matches, match) {
                return match ? ' ' + match : ''
              }
            )
          }
          module.exports = toSpaceCase
        },
        { 'to-no-case': 185 },
      ],
      185: [
        function (require, module, exports) {
          module.exports = toNoCase
          var hasSpace = /\s/,
            hasCamel = /[a-z][A-Z]/,
            hasSeparator = /[\W_]/
          function toNoCase(string) {
            return hasSpace.test(string)
              ? string.toLowerCase()
              : (hasSeparator.test(string) && (string = unseparate(string)),
                hasCamel.test(string) && (string = uncamelize(string)),
                string.toLowerCase())
          }
          var separatorSplitter = /[\W_]+(.|$)/g
          function unseparate(string) {
            return string.replace(separatorSplitter, function (m, next) {
              return next ? ' ' + next : ''
            })
          }
          var camelSplitter = /(.)([A-Z]+)/g
          function uncamelize(string) {
            return string.replace(
              camelSplitter,
              function (m, previous, uppers) {
                return previous + ' ' + uppers.toLowerCase().split('').join(' ')
              }
            )
          }
        },
        {},
      ],
      165: [
        function (require, module, exports) {
          function transform(url) {
            return check() ? 'https:' + url : 'http:' + url
          }
          function check() {
            return (
              'https:' == location.protocol ||
              'chrome-extension:' == location.protocol
            )
          }
          module.exports = function (url) {
            switch (arguments.length) {
              case 0:
                return check()
              case 1:
                return transform(url)
            }
          }
        },
        {},
      ],
      186: [
        function (require, module, exports) {
          var parse = require('url').parse
          module.exports = domain
          var regexp = /[a-z0-9][a-z0-9\-]*[a-z0-9]\.[a-z\.]{2,6}$/i
          function domain(url) {
            var host,
              match = parse(url).hostname.match(regexp)
            return match ? match[0] : ''
          }
        },
        { url: 61 },
      ],
      187: [
        function (require, module, exports) {
          var onload = require('script-onload'),
            tick = require('next-tick'),
            type = require('type')
          module.exports = function loadScript(options, fn) {
            if (!options) throw new Error('Cant load nothing...')
            'string' == type(options) && (options = { src: options })
            var https =
              'https:' === document.location.protocol ||
              'chrome-extension:' === document.location.protocol
            options.src &&
              0 === options.src.indexOf('//') &&
              (options.src = https
                ? 'https:' + options.src
                : 'http:' + options.src),
              https && options.https
                ? (options.src = options.https)
                : !https && options.http && (options.src = options.http)
            var script = document.createElement('script')
            return (
              (script.type = 'text/javascript'),
              (script.async = !0),
              (script.src = options.src),
              'function' == type(fn) && onload(script, fn),
              tick(function () {
                var firstScript = document.getElementsByTagName('script')[0]
                firstScript.parentNode.insertBefore(script, firstScript)
              }),
              script
            )
          }
        },
        { 'script-onload': 182, 'next-tick': 54, type: 43 },
      ],
      188: [
        function (require, module, exports) {
          var Facade = require('./facade')
          ;(module.exports = Facade),
            (Facade.Alias = require('./alias')),
            (Facade.Group = require('./group')),
            (Facade.Identify = require('./identify')),
            (Facade.Track = require('./track')),
            (Facade.Page = require('./page')),
            (Facade.Screen = require('./screen'))
        },
        {
          './facade': 190,
          './alias': 191,
          './group': 192,
          './identify': 193,
          './track': 194,
          './page': 195,
          './screen': 196,
        },
      ],
      190: [
        function (require, module, exports) {
          var traverse = require('isodate-traverse'),
            isEnabled = require('./is-enabled'),
            clone = require('./utils').clone,
            type = require('./utils').type,
            address = require('./address'),
            objCase = require('obj-case'),
            newDate = require('new-date')
          function Facade(obj) {
            obj.hasOwnProperty('timestamp')
              ? (obj.timestamp = newDate(obj.timestamp))
              : (obj.timestamp = new Date()),
              traverse(obj),
              (this.obj = obj)
          }
          function transform(obj) {
            var cloned
            return clone(obj)
          }
          ;(module.exports = Facade),
            address(Facade.prototype),
            (Facade.prototype.proxy = function (field) {
              var fields = field.split('.'),
                obj = this[(field = fields.shift())] || this.field(field)
              return obj
                ? ('function' == typeof obj && (obj = obj.call(this) || {}),
                  0 === fields.length
                    ? transform(obj)
                    : transform((obj = objCase(obj, fields.join('.')))))
                : obj
            }),
            (Facade.prototype.field = function (field) {
              var obj
              return transform(this.obj[field])
            }),
            (Facade.proxy = function (field) {
              return function () {
                return this.proxy(field)
              }
            }),
            (Facade.field = function (field) {
              return function () {
                return this.field(field)
              }
            }),
            (Facade.multi = function (path) {
              return function () {
                var multi = this.proxy(path + 's')
                if ('array' == type(multi)) return multi
                var one = this.proxy(path)
                return one && (one = [clone(one)]), one || []
              }
            }),
            (Facade.one = function (path) {
              return function () {
                var one = this.proxy(path)
                if (one) return one
                var multi = this.proxy(path + 's')
                return 'array' == type(multi) ? multi[0] : void 0
              }
            }),
            (Facade.prototype.json = function () {
              var ret = clone(this.obj)
              return this.type && (ret.type = this.type()), ret
            }),
            (Facade.prototype.context = Facade.prototype.options =
              function (integration) {
                var options = clone(this.obj.options || this.obj.context) || {}
                if (!integration) return clone(options)
                if (this.enabled(integration)) {
                  var integrations = this.integrations(),
                    value =
                      integrations[integration] ||
                      objCase(integrations, integration)
                  return 'boolean' == typeof value && (value = {}), value || {}
                }
              }),
            (Facade.prototype.enabled = function (integration) {
              var allEnabled = this.proxy('options.providers.all')
              'boolean' != typeof allEnabled &&
                (allEnabled = this.proxy('options.all')),
                'boolean' != typeof allEnabled &&
                  (allEnabled = this.proxy('integrations.all')),
                'boolean' != typeof allEnabled && (allEnabled = !0)
              var enabled = allEnabled && isEnabled(integration),
                options = this.integrations()
              if (
                (options.providers &&
                  options.providers.hasOwnProperty(integration) &&
                  (enabled = options.providers[integration]),
                options.hasOwnProperty(integration))
              ) {
                var settings = options[integration]
                enabled = 'boolean' != typeof settings || settings
              }
              return !!enabled
            }),
            (Facade.prototype.integrations = function () {
              return (
                this.obj.integrations ||
                this.proxy('options.providers') ||
                this.options()
              )
            }),
            (Facade.prototype.active = function () {
              var active = this.proxy('options.active')
              return null == active && (active = !0), active
            }),
            (Facade.prototype.sessionId = Facade.prototype.anonymousId =
              function () {
                return this.field('anonymousId') || this.field('sessionId')
              }),
            (Facade.prototype.groupId = Facade.proxy('options.groupId')),
            (Facade.prototype.traits = function (aliases) {
              var ret = this.proxy('options.traits') || {},
                id = this.userId()
              for (var alias in ((aliases = aliases || {}),
              id && (ret.id = id),
              aliases)) {
                var value =
                  null == this[alias]
                    ? this.proxy('options.traits.' + alias)
                    : this[alias]()
                null != value &&
                  ((ret[aliases[alias]] = value), delete ret[alias])
              }
              return ret
            }),
            (Facade.prototype.library = function () {
              var library = this.proxy('options.library')
              return library
                ? 'string' == typeof library
                  ? { name: library, version: null }
                  : library
                : { name: 'unknown', version: null }
            }),
            (Facade.prototype.userId = Facade.field('userId')),
            (Facade.prototype.channel = Facade.field('channel')),
            (Facade.prototype.timestamp = Facade.field('timestamp')),
            (Facade.prototype.userAgent = Facade.proxy('options.userAgent')),
            (Facade.prototype.ip = Facade.proxy('options.ip'))
        },
        {
          'isodate-traverse': 39,
          './is-enabled': 197,
          './utils': 198,
          './address': 199,
          'obj-case': 38,
          'new-date': 40,
        },
      ],
      197: [
        function (require, module, exports) {
          var disabled = { Salesforce: !0 }
          module.exports = function (integration) {
            return !disabled[integration]
          }
        },
        {},
      ],
      198: [
        function (require, module, exports) {
          try {
            ;(exports.inherit = require('inherit')),
              (exports.clone = require('clone')),
              (exports.type = require('type'))
          } catch (e) {
            ;(exports.inherit = require('inherit-component')),
              (exports.clone = require('clone-component')),
              (exports.type = require('type-component'))
          }
        },
        { inherit: 41, clone: 42, type: 43 },
      ],
      199: [
        function (require, module, exports) {
          var get = require('obj-case')
          module.exports = function (proto) {
            function trait(a, b) {
              return function () {
                var traits = this.traits(),
                  props = this.properties ? this.properties() : {}
                return (
                  get(traits, 'address.' + a) ||
                  get(traits, a) ||
                  (b ? get(traits, 'address.' + b) : null) ||
                  (b ? get(traits, b) : null) ||
                  get(props, 'address.' + a) ||
                  get(props, a) ||
                  (b ? get(props, 'address.' + b) : null) ||
                  (b ? get(props, b) : null)
                )
              }
            }
            ;(proto.zip = trait('postalCode', 'zip')),
              (proto.country = trait('country')),
              (proto.street = trait('street')),
              (proto.state = trait('state')),
              (proto.city = trait('city'))
          }
        },
        { 'obj-case': 38 },
      ],
      191: [
        function (require, module, exports) {
          var inherit = require('./utils').inherit,
            Facade = require('./facade')
          function Alias(dictionary) {
            Facade.call(this, dictionary)
          }
          ;(module.exports = Alias),
            inherit(Alias, Facade),
            (Alias.prototype.type = Alias.prototype.action =
              function () {
                return 'alias'
              }),
            (Alias.prototype.from = Alias.prototype.previousId =
              function () {
                return this.field('previousId') || this.field('from')
              }),
            (Alias.prototype.to = Alias.prototype.userId =
              function () {
                return this.field('userId') || this.field('to')
              })
        },
        { './utils': 198, './facade': 190 },
      ],
      192: [
        function (require, module, exports) {
          var inherit = require('./utils').inherit,
            address = require('./address'),
            isEmail = require('is-email'),
            newDate = require('new-date'),
            Facade = require('./facade')
          function Group(dictionary) {
            Facade.call(this, dictionary)
          }
          ;(module.exports = Group),
            inherit(Group, Facade),
            (Group.prototype.type = Group.prototype.action =
              function () {
                return 'group'
              }),
            (Group.prototype.groupId = Facade.field('groupId')),
            (Group.prototype.created = function () {
              var created =
                this.proxy('traits.createdAt') ||
                this.proxy('traits.created') ||
                this.proxy('properties.createdAt') ||
                this.proxy('properties.created')
              if (created) return newDate(created)
            }),
            (Group.prototype.email = function () {
              var email = this.proxy('traits.email')
              if (email) return email
              var groupId = this.groupId()
              return isEmail(groupId) ? groupId : void 0
            }),
            (Group.prototype.traits = function (aliases) {
              var ret = this.properties(),
                id = this.groupId()
              for (var alias in ((aliases = aliases || {}),
              id && (ret.id = id),
              aliases)) {
                var value =
                  null == this[alias]
                    ? this.proxy('traits.' + alias)
                    : this[alias]()
                null != value &&
                  ((ret[aliases[alias]] = value), delete ret[alias])
              }
              return ret
            }),
            (Group.prototype.name = Facade.proxy('traits.name')),
            (Group.prototype.industry = Facade.proxy('traits.industry')),
            (Group.prototype.employees = Facade.proxy('traits.employees')),
            (Group.prototype.properties = function () {
              return this.field('traits') || this.field('properties') || {}
            })
        },
        {
          './utils': 198,
          './address': 199,
          'is-email': 50,
          'new-date': 40,
          './facade': 190,
        },
      ],
      193: [
        function (require, module, exports) {
          var address = require('./address'),
            Facade = require('./facade'),
            isEmail = require('is-email'),
            newDate = require('new-date'),
            utils = require('./utils'),
            get = require('obj-case'),
            trim = require('trim'),
            inherit = utils.inherit,
            clone = utils.clone,
            type = utils.type
          function Identify(dictionary) {
            Facade.call(this, dictionary)
          }
          ;(module.exports = Identify),
            inherit(Identify, Facade),
            (Identify.prototype.type = Identify.prototype.action =
              function () {
                return 'identify'
              }),
            (Identify.prototype.traits = function (aliases) {
              var ret = this.field('traits') || {},
                id = this.userId()
              for (var alias in ((aliases = aliases || {}),
              id && (ret.id = id),
              aliases)) {
                var value =
                  null == this[alias]
                    ? this.proxy('traits.' + alias)
                    : this[alias]()
                null != value &&
                  ((ret[aliases[alias]] = value),
                  alias !== aliases[alias] && delete ret[alias])
              }
              return ret
            }),
            (Identify.prototype.email = function () {
              var email = this.proxy('traits.email')
              if (email) return email
              var userId = this.userId()
              return isEmail(userId) ? userId : void 0
            }),
            (Identify.prototype.created = function () {
              var created =
                this.proxy('traits.created') || this.proxy('traits.createdAt')
              if (created) return newDate(created)
            }),
            (Identify.prototype.companyCreated = function () {
              var created =
                this.proxy('traits.company.created') ||
                this.proxy('traits.company.createdAt')
              if (created) return newDate(created)
            }),
            (Identify.prototype.name = function () {
              var name = this.proxy('traits.name')
              if ('string' == typeof name) return trim(name)
              var firstName = this.firstName(),
                lastName = this.lastName()
              return firstName && lastName
                ? trim(firstName + ' ' + lastName)
                : void 0
            }),
            (Identify.prototype.firstName = function () {
              var firstName = this.proxy('traits.firstName')
              if ('string' == typeof firstName) return trim(firstName)
              var name = this.proxy('traits.name')
              return 'string' == typeof name ? trim(name).split(' ')[0] : void 0
            }),
            (Identify.prototype.lastName = function () {
              var lastName = this.proxy('traits.lastName')
              if ('string' == typeof lastName) return trim(lastName)
              var name = this.proxy('traits.name')
              if ('string' == typeof name) {
                var space = trim(name).indexOf(' ')
                if (-1 !== space) return trim(name.substr(space + 1))
              }
            }),
            (Identify.prototype.uid = function () {
              return this.userId() || this.username() || this.email()
            }),
            (Identify.prototype.description = function () {
              return (
                this.proxy('traits.description') ||
                this.proxy('traits.background')
              )
            }),
            (Identify.prototype.age = function () {
              var date = this.birthday(),
                age = get(this.traits(), 'age'),
                now
              return null != age
                ? age
                : 'date' == type(date)
                ? new Date().getFullYear() - date.getFullYear()
                : void 0
            }),
            (Identify.prototype.avatar = function () {
              var traits = this.traits()
              return (
                get(traits, 'avatar') ||
                get(traits, 'photoUrl') ||
                get(traits, 'avatarUrl')
              )
            }),
            (Identify.prototype.position = function () {
              var traits = this.traits()
              return get(traits, 'position') || get(traits, 'jobTitle')
            }),
            (Identify.prototype.username = Facade.proxy('traits.username')),
            (Identify.prototype.website = Facade.one('traits.website')),
            (Identify.prototype.websites = Facade.multi('traits.website')),
            (Identify.prototype.phone = Facade.one('traits.phone')),
            (Identify.prototype.phones = Facade.multi('traits.phone')),
            (Identify.prototype.address = Facade.proxy('traits.address')),
            (Identify.prototype.gender = Facade.proxy('traits.gender')),
            (Identify.prototype.birthday = Facade.proxy('traits.birthday'))
        },
        {
          './address': 199,
          './facade': 190,
          'is-email': 50,
          'new-date': 40,
          './utils': 198,
          'obj-case': 38,
          trim: 51,
        },
      ],
      194: [
        function (require, module, exports) {
          var inherit = require('./utils').inherit,
            clone = require('./utils').clone,
            type = require('./utils').type,
            Facade = require('./facade'),
            Identify = require('./identify'),
            isEmail = require('is-email'),
            get = require('obj-case')
          function Track(dictionary) {
            Facade.call(this, dictionary)
          }
          function currency(val) {
            if (val) {
              if ('number' == typeof val) return val
              if ('string' == typeof val)
                return (
                  (val = val.replace(/\$/g, '')),
                  (val = parseFloat(val)),
                  isNaN(val) ? void 0 : val
                )
            }
          }
          ;(module.exports = Track),
            inherit(Track, Facade),
            (Track.prototype.type = Track.prototype.action =
              function () {
                return 'track'
              }),
            (Track.prototype.event = Facade.field('event')),
            (Track.prototype.value = Facade.proxy('properties.value')),
            (Track.prototype.category = Facade.proxy('properties.category')),
            (Track.prototype.id = Facade.proxy('properties.id')),
            (Track.prototype.sku = Facade.proxy('properties.sku')),
            (Track.prototype.tax = Facade.proxy('properties.tax')),
            (Track.prototype.name = Facade.proxy('properties.name')),
            (Track.prototype.price = Facade.proxy('properties.price')),
            (Track.prototype.total = Facade.proxy('properties.total')),
            (Track.prototype.coupon = Facade.proxy('properties.coupon')),
            (Track.prototype.shipping = Facade.proxy('properties.shipping')),
            (Track.prototype.discount = Facade.proxy('properties.discount')),
            (Track.prototype.description = Facade.proxy(
              'properties.description'
            )),
            (Track.prototype.plan = Facade.proxy('properties.plan')),
            (Track.prototype.orderId = function () {
              return (
                this.proxy('properties.id') || this.proxy('properties.orderId')
              )
            }),
            (Track.prototype.subtotal = function () {
              var subtotal = get(this.properties(), 'subtotal'),
                total = this.total(),
                n
              return (
                subtotal ||
                (total
                  ? ((n = this.tax()) && (total -= n),
                    (n = this.shipping()) && (total -= n),
                    (n = this.discount()) && (total += n),
                    total)
                  : 0)
              )
            }),
            (Track.prototype.products = function () {
              var props = this.properties(),
                products = get(props, 'products')
              return 'array' == type(products) ? products : []
            }),
            (Track.prototype.quantity = function () {
              var props
              return (this.obj.properties || {}).quantity || 1
            }),
            (Track.prototype.currency = function () {
              var props
              return (this.obj.properties || {}).currency || 'USD'
            }),
            (Track.prototype.referrer = Facade.proxy('properties.referrer')),
            (Track.prototype.query = Facade.proxy('options.query')),
            (Track.prototype.properties = function (aliases) {
              var ret = this.field('properties') || {}
              for (var alias in (aliases = aliases || {})) {
                var value =
                  null == this[alias]
                    ? this.proxy('properties.' + alias)
                    : this[alias]()
                null != value &&
                  ((ret[aliases[alias]] = value), delete ret[alias])
              }
              return ret
            }),
            (Track.prototype.username = function () {
              return (
                this.proxy('traits.username') ||
                this.proxy('properties.username') ||
                this.userId() ||
                this.sessionId()
              )
            }),
            (Track.prototype.email = function () {
              var email = this.proxy('traits.email')
              if ((email = email || this.proxy('properties.email')))
                return email
              var userId = this.userId()
              return isEmail(userId) ? userId : void 0
            }),
            (Track.prototype.revenue = function () {
              var revenue = this.proxy('properties.revenue'),
                event = this.event()
              return (
                !revenue &&
                  event &&
                  event.match(/completed ?order/i) &&
                  (revenue = this.proxy('properties.total')),
                currency(revenue)
              )
            }),
            (Track.prototype.cents = function () {
              var revenue = this.revenue()
              return 'number' != typeof revenue
                ? this.value() || 0
                : 100 * revenue
            }),
            (Track.prototype.identify = function () {
              var json = this.json()
              return (json.traits = this.traits()), new Identify(json)
            })
        },
        {
          './utils': 198,
          './facade': 190,
          './identify': 193,
          'is-email': 50,
          'obj-case': 38,
        },
      ],
      195: [
        function (require, module, exports) {
          var inherit = require('./utils').inherit,
            Facade = require('./facade'),
            Track = require('./track')
          function Page(dictionary) {
            Facade.call(this, dictionary)
          }
          ;(module.exports = Page),
            inherit(Page, Facade),
            (Page.prototype.type = Page.prototype.action =
              function () {
                return 'page'
              }),
            (Page.prototype.category = Facade.field('category')),
            (Page.prototype.name = Facade.field('name')),
            (Page.prototype.title = Facade.proxy('properties.title')),
            (Page.prototype.path = Facade.proxy('properties.path')),
            (Page.prototype.url = Facade.proxy('properties.url')),
            (Page.prototype.referrer = function () {
              return (
                this.proxy('properties.referrer') ||
                this.proxy('context.referrer.url')
              )
            }),
            (Page.prototype.properties = function () {
              var props = this.field('properties') || {},
                category = this.category(),
                name = this.name()
              return (
                category && (props.category = category),
                name && (props.name = name),
                props
              )
            }),
            (Page.prototype.fullName = function () {
              var category = this.category(),
                name = this.name()
              return name && category ? category + ' ' + name : name
            }),
            (Page.prototype.event = function (name) {
              return name ? 'Viewed ' + name + ' Page' : 'Loaded a Page'
            }),
            (Page.prototype.track = function (name) {
              var props = this.properties()
              return new Track({
                event: this.event(name),
                timestamp: this.timestamp(),
                context: this.context(),
                properties: props,
              })
            })
        },
        { './utils': 198, './facade': 190, './track': 194 },
      ],
      196: [
        function (require, module, exports) {
          var inherit = require('./utils').inherit,
            Page = require('./page'),
            Track = require('./track')
          function Screen(dictionary) {
            Page.call(this, dictionary)
          }
          ;(module.exports = Screen),
            inherit(Screen, Page),
            (Screen.prototype.type = Screen.prototype.action =
              function () {
                return 'screen'
              }),
            (Screen.prototype.event = function (name) {
              return name ? 'Viewed ' + name + ' Screen' : 'Loaded a Screen'
            }),
            (Screen.prototype.track = function (name) {
              var props = this.properties()
              return new Track({
                event: this.event(name),
                timestamp: this.timestamp(),
                context: this.context(),
                properties: props,
              })
            })
        },
        { './utils': 198, './page': 195, './track': 194 },
      ],
      189: [
        function (require, module, exports) {
          var encode = encodeURIComponent,
            decode = decodeURIComponent,
            trim = require('trim'),
            type = require('type')
          ;(exports.parse = function (str) {
            if ('string' != typeof str) return {}
            if ('' == (str = trim(str))) return {}
            '?' == str.charAt(0) && (str = str.slice(1))
            for (
              var obj = {}, pairs = str.split('&'), i = 0;
              i < pairs.length;
              i++
            ) {
              var parts = pairs[i].split('='),
                key = decode(parts[0]),
                m
              ;(m = /(\w+)\[(\d+)\]/.exec(key))
                ? ((obj[m[1]] = obj[m[1]] || []),
                  (obj[m[1]][m[2]] = decode(parts[1])))
                : (obj[parts[0]] = null == parts[1] ? '' : decode(parts[1]))
            }
            return obj
          }),
            (exports.stringify = function (obj) {
              if (!obj) return ''
              var pairs = []
              for (var key in obj) {
                var value = obj[key]
                if ('array' != type(value))
                  pairs.push(encode(key) + '=' + encode(obj[key]))
                else
                  for (var i = 0; i < value.length; ++i)
                    pairs.push(
                      encode(key + '[' + i + ']') + '=' + encode(value[i])
                    )
              }
              return pairs.join('&')
            })
        },
        { trim: 51, type: 43 },
      ],
      200: [
        function (require, module, exports) {
          function defaults(dest, defaults) {
            for (var prop in defaults)
              prop in dest || (dest[prop] = defaults[prop])
            return dest
          }
          module.exports = defaults
        },
        {},
      ],
      201: [
        function (require, module, exports) {
          var each = require('each'),
            body = !1,
            callbacks = []
          module.exports = function onBody(callback) {
            body ? call(callback) : callbacks.push(callback)
          }
          var interval = setInterval(function () {
            document.body &&
              ((body = !0), each(callbacks, call), clearInterval(interval))
          }, 5)
          function call(callback) {
            callback(document.body)
          }
        },
        { each: 174 },
      ],
      91: [
        function (require, module, exports) {},
        {
          'load-date': 202,
          domify: 183,
          each: 4,
          'analytics.js-integration': 163,
          is: 16,
          'on-body': 201,
          'use-https': 165,
        },
      ],
      202: [
        function (require, module, exports) {
          var time = new Date(),
            perf = window.performance
          perf &&
            perf.timing &&
            perf.timing.responseEnd &&
            (time = new Date(perf.timing.responseEnd)),
            (module.exports = time)
        },
        {},
      ],
      203: [
        function (require, module, exports) {
          function toIsoString(date) {
            return (
              date.getUTCFullYear() +
              '-' +
              pad(date.getUTCMonth() + 1) +
              '-' +
              pad(date.getUTCDate()) +
              'T' +
              pad(date.getUTCHours()) +
              ':' +
              pad(date.getUTCMinutes()) +
              ':' +
              pad(date.getUTCSeconds()) +
              '.' +
              String((date.getUTCMilliseconds() / 1e3).toFixed(3)).slice(2, 5) +
              'Z'
            )
          }
          function pad(number) {
            var n = number.toString()
            return 1 === n.length ? '0' + n : n
          }
          module.exports = toIsoString
        },
        {},
      ],
      204: [
        function (require, module, exports) {
          function generate(name, options) {
            return (
              (options = options || {}),
              function (args) {
                ;(args = [].slice.call(arguments)),
                  window[name] || (window[name] = []),
                  !1 === options.wrap
                    ? window[name].push.apply(window[name], args)
                    : window[name].push(args)
              }
            )
          }
          module.exports = generate
        },
        {},
      ],
      205: [
        function (require, module, exports) {
          function throttle(func, wait) {
            var rtn,
              last = 0
            return function throttled() {
              var now = new Date().getTime(),
                delta = now - last
              return (
                delta >= wait &&
                  ((rtn = func.apply(this, arguments)), (last = now)),
                rtn
              )
            }
          }
          module.exports = throttle
        },
        {},
      ],
      206: [
        function (require, module, exports) {
          var callback = require('callback')
          function when(condition, fn, interval) {
            if (condition()) return callback.async(fn)
            var ref = setInterval(function () {
              condition() && (callback(fn), clearInterval(ref))
            }, interval || 10)
          }
          module.exports = when
        },
        { callback: 10 },
      ],
      207: [
        function (require, module, exports) {
          var type = require('type')
          try {
            var clone = require('clone')
          } catch (e) {
            var clone = require('clone-component')
          }
          function alias(obj, method) {
            switch (type(method)) {
              case 'object':
                return aliasByDictionary(clone(obj), method)
              case 'function':
                return aliasByFunction(clone(obj), method)
            }
          }
          function aliasByDictionary(obj, aliases) {
            for (var key in aliases)
              void 0 !== obj[key] &&
                ((obj[aliases[key]] = obj[key]), delete obj[key])
            return obj
          }
          function aliasByFunction(obj, convert) {
            var output = {}
            for (var key in obj) output[convert(key)] = obj[key]
            return output
          }
          module.exports = alias
        },
        { type: 43, clone: 42 },
      ],
      208: [
        function (require, module, exports) {
          var is = require('is')
          try {
            var clone = require('clone')
          } catch (e) {
            var clone = require('clone-component')
          }
          function convertDates(obj, convert) {
            for (var key in (obj = clone(obj))) {
              var val = obj[key]
              is.date(val) && (obj[key] = convert(val)),
                is.object(val) && (obj[key] = convertDates(val, convert))
            }
            return obj
          }
          module.exports = convertDates
        },
        { is: 16, clone: 11 },
      ],
      209: [
        function (require, module, exports) {
          module.exports = onError
          var callbacks = []
          function handler() {
            for (var i = 0, fn; (fn = callbacks[i]); i++)
              fn.apply(this, arguments)
          }
          function onError(fn) {
            callbacks.push(fn),
              window.onerror != handler &&
                (callbacks.push(window.onerror), (window.onerror = handler))
          }
          'function' == typeof window.onerror && callbacks.push(window.onerror),
            (window.onerror = handler)
        },
        {},
      ],
      100: [
        function (require, module, exports) {},
        { each: 4, 'analytics.js-integration': 163, 'global-queue': 204 },
      ],
      101: [
        function (require, module, exports) {},
        {
          bind: 52,
          domify: 183,
          each: 4,
          extend: 65,
          'analytics.js-integration': 163,
          json: 56,
        },
      ],
      210: [
        function (require, module, exports) {
          var toSpace = require('to-space-case')
          function toCamelCase(string) {
            return toSpace(string).replace(
              /\s(\w)/g,
              function (matches, letter) {
                return letter.toUpperCase()
              }
            )
          }
          module.exports = toCamelCase
        },
        { 'to-space-case': 184 },
      ],
      126: [
        function (require, module, exports) {
          var alias = require('alias'),
            dates = require('convert-dates'),
            del = require('obj-case').del,
            each = require('each'),
            includes = require('includes'),
            integration = require('analytics.js-integration'),
            is = require('is'),
            iso = require('to-iso-string'),
            some = require('some'),
            Mixpanel = (module.exports = integration('Mixpanel')
              .global('mixpanel')
              .option('increments', [])
              .option('cookieName', '')
              .option('crossSubdomainCookie', !1)
              .option('secureCookie', !1)
              .option('nameTag', !0)
              .option('pageview', !1)
              .option('people', !1)
              .option('token', '')
              .option('trackAllPages', !1)
              .option('trackNamedPages', !0)
              .option('trackCategorizedPages', !0)
              .tag(
                '<script src="//cdn.mxpnl.com/libs/mixpanel-2-latest.min.js">'
              )),
            optionsAliases = {
              cookieName: 'cookie_name',
              crossSubdomainCookie: 'cross_subdomain_cookie',
              secureCookie: 'secure_cookie',
            }
          ;(Mixpanel.prototype.initialize = function () {
            var c, a, b, d, h, e
            ;(c = document),
              (a = window.mixpanel || []),
              (window.mixpanel = a),
              (a._i = []),
              (a.init = function (b, c, f) {
                function d(a, b) {
                  var c = b.split('.')
                  2 == c.length && ((a = a[c[0]]), (b = c[1])),
                    (a[b] = function () {
                      a.push(
                        [b].concat(Array.prototype.slice.call(arguments, 0))
                      )
                    })
                }
                var g = a
                for (
                  void 0 !== f ? (g = a[f] = []) : (f = 'mixpanel'),
                    g.people = g.people || [],
                    h = [
                      'disable',
                      'track',
                      'track_pageview',
                      'track_links',
                      'track_forms',
                      'register',
                      'register_once',
                      'unregister',
                      'identify',
                      'alias',
                      'name_tag',
                      'set_config',
                      'people.set',
                      'people.increment',
                      'people.track_charge',
                      'people.append',
                    ],
                    e = 0;
                  e < h.length;
                  e++
                )
                  d(g, h[e])
                a._i.push([b, c, f])
              }),
              (a.__SV = 1.2),
              (this.options.increments = lowercase(this.options.increments))
            var options = alias(this.options, optionsAliases)
            window.mixpanel.init(options.token, options), this.load(this.ready)
          }),
            (Mixpanel.prototype.loaded = function () {
              return !(!window.mixpanel || !window.mixpanel.config)
            }),
            (Mixpanel.prototype.page = function (page) {
              var category = page.category(),
                name = page.fullName(),
                opts = this.options
              opts.trackAllPages && this.track(page.track()),
                category &&
                  opts.trackCategorizedPages &&
                  this.track(page.track(category)),
                name && opts.trackNamedPages && this.track(page.track(name))
            })
          var traitAliases = {
            created: '$created',
            email: '$email',
            firstName: '$first_name',
            lastName: '$last_name',
            lastSeen: '$last_seen',
            name: '$name',
            username: '$username',
            phone: '$phone',
          }
          function lowercase(arr) {
            for (var ret = new Array(arr.length), i = 0; i < arr.length; ++i)
              ret[i] = String(arr[i]).toLowerCase()
            return ret
          }
          ;(Mixpanel.prototype.identify = function (identify) {
            var username = identify.username(),
              email = identify.email(),
              id = identify.userId()
            id && window.mixpanel.identify(id)
            var nametag = email || username || id
            nametag && window.mixpanel.name_tag(nametag)
            var traits = identify.traits(traitAliases)
            traits.$created && del(traits, 'createdAt'),
              window.mixpanel.register(dates(traits, iso)),
              this.options.people && window.mixpanel.people.set(traits)
          }),
            (Mixpanel.prototype.track = function (track) {
              var increments = this.options.increments,
                increment = track.event().toLowerCase(),
                people = this.options.people,
                props = track.properties(),
                revenue = track.revenue()
              delete props.distinct_id,
                delete props.ip,
                delete props.mp_name_tag,
                delete props.mp_note,
                delete props.token,
                each(props, function (key, val) {
                  is.array(val) &&
                    some(val, is.object) &&
                    (props[key] = val.length)
                }),
                people &&
                  includes(increment, increments) &&
                  (window.mixpanel.people.increment(track.event()),
                  window.mixpanel.people.set(
                    'Last ' + track.event(),
                    new Date()
                  )),
                (props = dates(props, iso)),
                window.mixpanel.track(track.event(), props),
                revenue &&
                  people &&
                  window.mixpanel.people.track_charge(revenue)
            }),
            (Mixpanel.prototype.alias = function (alias) {
              var mp = window.mixpanel,
                to = alias.to()
              ;(mp.get_distinct_id && mp.get_distinct_id() === to) ||
                (mp.get_property &&
                  mp.get_property('$people_distinct_id') === to) ||
                mp.alias(to, alias.from())
            })
        },
        {
          alias: 207,
          'convert-dates': 208,
          'obj-case': 38,
          each: 4,
          includes: 67,
          'analytics.js-integration': 163,
          is: 16,
          'to-iso-string': 203,
          some: 214,
        },
      ],
      214: [
        function (require, module, exports) {
          var some = [].some
          module.exports = function (arr, fn) {
            if (some) return some.call(arr, fn)
            for (var i = 0, l = arr.length; i < l; ++i)
              if (fn(arr[i], i)) return !0
            return !1
          }
        },
        {},
      ],
      126: [
        function (require, module, exports) {
          var alias = require('alias'),
            dates = require('convert-dates'),
            del = require('obj-case').del,
            each = require('each'),
            includes = require('includes'),
            integration = require('analytics.js-integration'),
            is = require('is'),
            iso = require('to-iso-string'),
            some = require('some'),
            Mixpanel = (module.exports = integration('Mixpanel')
              .global('mixpanel')
              .option('increments', [])
              .option('cookieName', '')
              .option('crossSubdomainCookie', !1)
              .option('secureCookie', !1)
              .option('nameTag', !0)
              .option('pageview', !1)
              .option('people', !1)
              .option('token', '')
              .option('trackAllPages', !1)
              .option('trackNamedPages', !0)
              .option('trackCategorizedPages', !0)
              .tag(
                '<script src="//cdn.mxpnl.com/libs/mixpanel-2-latest.min.js">'
              )),
            optionsAliases = {
              cookieName: 'cookie_name',
              crossSubdomainCookie: 'cross_subdomain_cookie',
              secureCookie: 'secure_cookie',
            }
          ;(Mixpanel.prototype.initialize = function () {
            var c, a, b, d, h, e
            ;(c = document),
              (a = window.mixpanel || []),
              (window.mixpanel = a),
              (a._i = []),
              (a.init = function (b, c, f) {
                function d(a, b) {
                  var c = b.split('.')
                  2 == c.length && ((a = a[c[0]]), (b = c[1])),
                    (a[b] = function () {
                      a.push(
                        [b].concat(Array.prototype.slice.call(arguments, 0))
                      )
                    })
                }
                var g = a
                for (
                  void 0 !== f ? (g = a[f] = []) : (f = 'mixpanel'),
                    g.people = g.people || [],
                    h = [
                      'disable',
                      'track',
                      'track_pageview',
                      'track_links',
                      'track_forms',
                      'register',
                      'register_once',
                      'unregister',
                      'identify',
                      'alias',
                      'name_tag',
                      'set_config',
                      'people.set',
                      'people.increment',
                      'people.track_charge',
                      'people.append',
                    ],
                    e = 0;
                  e < h.length;
                  e++
                )
                  d(g, h[e])
                a._i.push([b, c, f])
              }),
              (a.__SV = 1.2),
              (this.options.increments = lowercase(this.options.increments))
            var options = alias(this.options, optionsAliases)
            window.mixpanel.init(options.token, options), this.load(this.ready)
          }),
            (Mixpanel.prototype.loaded = function () {
              return !(!window.mixpanel || !window.mixpanel.config)
            }),
            (Mixpanel.prototype.page = function (page) {
              var category = page.category(),
                name = page.fullName(),
                opts = this.options
              opts.trackAllPages && this.track(page.track()),
                category &&
                  opts.trackCategorizedPages &&
                  this.track(page.track(category)),
                name && opts.trackNamedPages && this.track(page.track(name))
            })
          var traitAliases = {
            created: '$created',
            email: '$email',
            firstName: '$first_name',
            lastName: '$last_name',
            lastSeen: '$last_seen',
            name: '$name',
            username: '$username',
            phone: '$phone',
          }
          function lowercase(arr) {
            for (var ret = new Array(arr.length), i = 0; i < arr.length; ++i)
              ret[i] = String(arr[i]).toLowerCase()
            return ret
          }
          ;(Mixpanel.prototype.identify = function (identify) {
            var username = identify.username(),
              email = identify.email(),
              id = identify.userId()
            id && window.mixpanel.identify(id)
            var nametag = email || username || id
            nametag && window.mixpanel.name_tag(nametag)
            var traits = identify.traits(traitAliases)
            traits.$created && del(traits, 'createdAt'),
              window.mixpanel.register(dates(traits, iso)),
              this.options.people && window.mixpanel.people.set(traits)
          }),
            (Mixpanel.prototype.track = function (track) {
              var increments = this.options.increments,
                increment = track.event().toLowerCase(),
                people = this.options.people,
                props = track.properties(),
                revenue = track.revenue()
              delete props.distinct_id,
                delete props.ip,
                delete props.mp_name_tag,
                delete props.mp_note,
                delete props.token,
                each(props, function (key, val) {
                  is.array(val) &&
                    some(val, is.object) &&
                    (props[key] = val.length)
                }),
                people &&
                  includes(increment, increments) &&
                  (window.mixpanel.people.increment(track.event()),
                  window.mixpanel.people.set(
                    'Last ' + track.event(),
                    new Date()
                  )),
                (props = dates(props, iso)),
                window.mixpanel.track(track.event(), props),
                revenue &&
                  people &&
                  window.mixpanel.people.track_charge(revenue)
            }),
            (Mixpanel.prototype.alias = function (alias) {
              var mp = window.mixpanel,
                to = alias.to()
              ;(mp.get_distinct_id && mp.get_distinct_id() === to) ||
                (mp.get_property &&
                  mp.get_property('$people_distinct_id') === to) ||
                mp.alias(to, alias.from())
            })
        },
        {
          alias: 207,
          'convert-dates': 208,
          'obj-case': 38,
          each: 4,
          includes: 67,
          'analytics.js-integration': 163,
          is: 16,
          'to-iso-string': 203,
          some: 214,
        },
      ],
      214: [
        function (require, module, exports) {
          var some = [].some
          module.exports = function (arr, fn) {
            if (some) return some.call(arr, fn)
            for (var i = 0, l = arr.length; i < l; ++i)
              if (fn(arr[i], i)) return !0
            return !1
          }
        },
        {},
      ],
      108: [
        function (require, module, exports) {
          var Track = require('facade').Track,
            defaults = require('defaults'),
            dot = require('obj-case'),
            each = require('each'),
            integration = require('analytics.js-integration'),
            is = require('is'),
            keys = require('object').keys,
            len = require('object').length,
            push = require('global-queue')('_gaq'),
            select = require('select'),
            useHttps = require('use-https'),
            user
          module.exports = exports = function (analytics) {
            analytics.addIntegration(GA), (user = analytics.user())
          }
          var GA = (exports.Integration = integration('Google Analytics')
            .readyOnLoad()
            .global('ga')
            .global('gaplugins')
            .global('_gaq')
            .global('GoogleAnalyticsObject')
            .option('anonymizeIp', !1)
            .option('classic', !1)
            .option('dimensions', {})
            .option('domain', 'auto')
            .option('doubleClick', !1)
            .option('enhancedEcommerce', !1)
            .option('enhancedLinkAttribution', !1)
            .option('ignoredReferrers', null)
            .option('includeSearch', !1)
            .option('metrics', {})
            .option('nonInteraction', !1)
            .option('sendUserId', !1)
            .option('siteSpeedSampleRate', 1)
            .option('trackCategorizedPages', !0)
            .option('trackNamedPages', !0)
            .option('trackingId', '')
            .tag(
              'library',
              '<script src="//www.google-analytics.com/analytics.js">'
            )
            .tag(
              'double click',
              '<script src="//stats.g.doubleclick.net/dc.js">'
            )
            .tag('http', '<script src="http://www.google-analytics.com/ga.js">')
            .tag(
              'https',
              '<script src="https://ssl.google-analytics.com/ga.js">'
            ))
          function path(properties, options) {
            if (properties) {
              var str = properties.path
              return (
                options.includeSearch &&
                  properties.search &&
                  (str += properties.search),
                str
              )
            }
          }
          function formatValue(value) {
            return !value || value < 0 ? 0 : Math.round(value)
          }
          function metrics(obj, data) {
            for (
              var dimensions = data.dimensions,
                metrics = data.metrics,
                names = keys(metrics).concat(keys(dimensions)),
                ret = {},
                i = 0;
              i < names.length;
              ++i
            ) {
              var name = names[i],
                key = metrics[name] || dimensions[name],
                value = dot(obj, name) || obj[name]
              null != value && (ret[key] = value)
            }
            return ret
          }
          GA.on('construct', function (integration) {
            integration.options.classic
              ? ((integration.initialize = integration.initializeClassic),
                (integration.loaded = integration.loadedClassic),
                (integration.page = integration.pageClassic),
                (integration.track = integration.trackClassic),
                (integration.completedOrder =
                  integration.completedOrderClassic))
              : integration.options.enhancedEcommerce &&
                ((integration.viewedProduct =
                  integration.viewedProductEnhanced),
                (integration.clickedProduct =
                  integration.clickedProductEnhanced),
                (integration.addedProduct = integration.addedProductEnhanced),
                (integration.removedProduct =
                  integration.removedProductEnhanced),
                (integration.startedOrder = integration.startedOrderEnhanced),
                (integration.viewedCheckoutStep =
                  integration.viewedCheckoutStepEnhanced),
                (integration.completedCheckoutStep =
                  integration.completedCheckoutStepEnhanced),
                (integration.updatedOrder = integration.updatedOrderEnhanced),
                (integration.completedOrder =
                  integration.completedOrderEnhanced),
                (integration.refundedOrder = integration.refundedOrderEnhanced),
                (integration.viewedPromotion =
                  integration.viewedPromotionEnhanced),
                (integration.clickedPromotion =
                  integration.clickedPromotionEnhanced))
          }),
            (GA.prototype.initialize = function () {
              var opts = this.options
              ;(window.GoogleAnalyticsObject = 'ga'),
                (window.ga =
                  window.ga ||
                  function () {
                    ;(window.ga.q = window.ga.q || []),
                      window.ga.q.push(arguments)
                  }),
                (window.ga.l = new Date().getTime()),
                'localhost' === window.location.hostname &&
                  (opts.domain = 'none'),
                window.ga('create', opts.trackingId, {
                  cookieDomain: opts.domain || GA.prototype.defaults.domain,
                  siteSpeedSampleRate: opts.siteSpeedSampleRate,
                  allowLinker: !0,
                }),
                opts.doubleClick && window.ga('require', 'displayfeatures'),
                opts.sendUserId &&
                  user.id() &&
                  window.ga('set', 'userId', user.id()),
                opts.anonymizeIp && window.ga('set', 'anonymizeIp', !0)
              var custom = metrics(user.traits(), opts)
              len(custom) && window.ga('set', custom),
                this.load('library', this.ready)
            }),
            (GA.prototype.loaded = function () {
              return !!window.gaplugins
            }),
            (GA.prototype.page = function (page) {
              var category = page.category(),
                props = page.properties(),
                name = page.fullName(),
                opts = this.options,
                campaign = page.proxy('context.campaign') || {},
                pageview = {},
                pagePath = path(props, this.options),
                pageTitle = name || props.title,
                track
              ;(this._category = category),
                (pageview.page = pagePath),
                (pageview.title = pageTitle),
                (pageview.location = props.url),
                campaign.name && (pageview.campaignName = campaign.name),
                campaign.source && (pageview.campaignSource = campaign.source),
                campaign.medium && (pageview.campaignMedium = campaign.medium),
                campaign.content &&
                  (pageview.campaignContent = campaign.content),
                campaign.term && (pageview.campaignKeyword = campaign.term)
              var custom = metrics(props, opts)
              len(custom) && window.ga('set', custom),
                window.ga('set', { page: pagePath, title: pageTitle }),
                window.ga('send', 'pageview', pageview),
                category &&
                  this.options.trackCategorizedPages &&
                  ((track = page.track(category)),
                  this.track(track, { nonInteraction: 1 })),
                name &&
                  this.options.trackNamedPages &&
                  ((track = page.track(name)),
                  this.track(track, { nonInteraction: 1 }))
            }),
            (GA.prototype.identify = function (identify) {
              var opts = this.options
              opts.sendUserId &&
                identify.userId() &&
                window.ga('set', 'userId', identify.userId())
              var custom = metrics(user.traits(), opts)
              len(custom) && window.ga('set', custom)
            }),
            (GA.prototype.track = function (track, options) {
              var contextOpts = track.options(this.name),
                interfaceOpts = this.options,
                opts = defaults(options || {}, contextOpts)
              opts = defaults(opts, interfaceOpts)
              var props = track.properties(),
                campaign = track.proxy('context.campaign') || {},
                custom = metrics(props, interfaceOpts)
              len(custom) && window.ga('set', custom)
              var payload = {
                eventAction: track.event(),
                eventCategory: props.category || this._category || 'All',
                eventLabel: props.label,
                eventValue: formatValue(props.value || track.revenue()),
                nonInteraction: !(
                  !props.nonInteraction && !opts.nonInteraction
                ),
              }
              campaign.name && (payload.campaignName = campaign.name),
                campaign.source && (payload.campaignSource = campaign.source),
                campaign.medium && (payload.campaignMedium = campaign.medium),
                campaign.content &&
                  (payload.campaignContent = campaign.content),
                campaign.term && (payload.campaignKeyword = campaign.term),
                window.ga('send', 'event', payload)
            }),
            (GA.prototype.completedOrder = function (track) {
              var total = track.total() || track.revenue() || 0,
                orderId = track.orderId(),
                products = track.products(),
                props = track.properties()
              orderId &&
                (this.ecommerce ||
                  (window.ga('require', 'ecommerce'), (this.ecommerce = !0)),
                window.ga('ecommerce:addTransaction', {
                  affiliation: props.affiliation,
                  shipping: track.shipping(),
                  revenue: total,
                  tax: track.tax(),
                  id: orderId,
                  currency: track.currency(),
                }),
                each(products, function (product) {
                  var productTrack = createProductTrack(track, product)
                  window.ga('ecommerce:addItem', {
                    category: productTrack.category(),
                    quantity: productTrack.quantity(),
                    price: productTrack.price(),
                    name: productTrack.name(),
                    sku: productTrack.sku(),
                    id: orderId,
                    currency: productTrack.currency(),
                  })
                }),
                window.ga('ecommerce:send'))
            }),
            (GA.prototype.initializeClassic = function () {
              var opts = this.options,
                anonymize = opts.anonymizeIp,
                domain = opts.domain,
                enhanced = opts.enhancedLinkAttribution,
                ignore = opts.ignoredReferrers,
                sample = opts.siteSpeedSampleRate
              if (
                ((window._gaq = window._gaq || []),
                push('_setAccount', opts.trackingId),
                push('_setAllowLinker', !0),
                anonymize && push('_gat._anonymizeIp'),
                domain && push('_setDomainName', domain),
                sample && push('_setSiteSpeedSampleRate', sample),
                enhanced)
              ) {
                var protocol =
                    'https:' === document.location.protocol
                      ? 'https:'
                      : 'http:',
                  pluginUrl
                push(
                  '_require',
                  'inpage_linkid',
                  protocol +
                    '//www.google-analytics.com/plugins/ga/inpage_linkid.js'
                )
              }
              if (
                (ignore &&
                  (is.array(ignore) || (ignore = [ignore]),
                  each(ignore, function (domain) {
                    push('_addIgnoredRef', domain)
                  })),
                this.options.doubleClick)
              )
                this.load('double click', this.ready)
              else {
                var name = useHttps() ? 'https' : 'http'
                this.load(name, this.ready)
              }
            }),
            (GA.prototype.loadedClassic = function () {
              return !(
                !window._gaq || window._gaq.push === Array.prototype.push
              )
            }),
            (GA.prototype.pageClassic = function (page) {
              var category = page.category(),
                props = page.properties(),
                name = page.fullName(),
                track
              push('_trackPageview', path(props, this.options)),
                category &&
                  this.options.trackCategorizedPages &&
                  ((track = page.track(category)),
                  this.track(track, { nonInteraction: 1 })),
                name &&
                  this.options.trackNamedPages &&
                  ((track = page.track(name)),
                  this.track(track, { nonInteraction: 1 }))
            }),
            (GA.prototype.trackClassic = function (track, options) {
              var opts = options || track.options(this.name),
                props = track.properties(),
                revenue = track.revenue(),
                event = track.event(),
                category = this._category || props.category || 'All',
                label = props.label,
                value = formatValue(revenue || props.value),
                nonInteraction = !(
                  !props.nonInteraction && !opts.nonInteraction
                )
              push('_trackEvent', category, event, label, value, nonInteraction)
            }),
            (GA.prototype.completedOrderClassic = function (track) {
              var total = track.total() || track.revenue() || 0,
                orderId = track.orderId(),
                products = track.products() || [],
                props = track.properties(),
                currency = track.currency()
              orderId &&
                (push(
                  '_addTrans',
                  orderId,
                  props.affiliation,
                  total,
                  track.tax(),
                  track.shipping(),
                  track.city(),
                  track.state(),
                  track.country()
                ),
                each(products, function (product) {
                  var track = new Track({ properties: product })
                  push(
                    '_addItem',
                    orderId,
                    track.sku(),
                    track.name(),
                    track.category(),
                    track.price(),
                    track.quantity()
                  )
                }),
                push('_set', 'currencyCode', currency),
                push('_trackTrans'))
            }),
            (GA.prototype.loadEnhancedEcommerce = function (track) {
              this.enhancedEcommerceLoaded ||
                (window.ga('require', 'ec'),
                (this.enhancedEcommerceLoaded = !0)),
                window.ga('set', '&cu', track.currency())
            }),
            (GA.prototype.pushEnhancedEcommerce = function (track) {
              window.ga(
                'send',
                'event',
                track.category() || 'EnhancedEcommerce',
                track.event(),
                { nonInteraction: 1 }
              )
            }),
            (GA.prototype.startedOrderEnhanced = function (track) {
              this.viewedCheckoutStep(track)
            }),
            (GA.prototype.updatedOrderEnhanced = function (track) {
              this.startedOrderEnhanced(track)
            }),
            (GA.prototype.viewedCheckoutStepEnhanced = function (track) {
              var products = track.products(),
                props = track.properties(),
                options = extractCheckoutOptions(props)
              this.loadEnhancedEcommerce(track),
                each(products, function (product) {
                  var productTrack
                  enhancedEcommerceTrackProduct(
                    createProductTrack(track, product)
                  )
                }),
                window.ga('ec:setAction', 'checkout', {
                  step: props.step || 1,
                  option: options || void 0,
                }),
                this.pushEnhancedEcommerce(track)
            }),
            (GA.prototype.completedCheckoutStepEnhanced = function (track) {
              var props = track.properties(),
                options = extractCheckoutOptions(props)
              props.step &&
                options &&
                (this.loadEnhancedEcommerce(track),
                window.ga('ec:setAction', 'checkout_option', {
                  step: props.step || 1,
                  option: options,
                }),
                window.ga('send', 'event', 'Checkout', 'Option'))
            })
          var STRIPE_ZERO_DECIMAL_CURRENCIES = new Set([
            'BIF',
            'CLP',
            'DJF',
            'GNF',
            'JPY',
            'KMF',
            'KRW',
            'MGA',
            'PYG',
            'RWF',
            'UGX',
            'VND',
            'VUV',
            'XAF',
            'XOF',
            'XPF',
          ])
          function enhancedEcommerceTrackProduct(track) {
            var props = track.properties(),
              price = track.price()
            STRIPE_ZERO_DECIMAL_CURRENCIES.has(track.currency()) &&
              (price *= 100),
              window.ga('ec:addProduct', {
                id: track.id() || track.sku(),
                name: track.name(),
                category: track.category(),
                quantity: track.quantity(),
                price: price,
                brand: props.brand,
                variant: props.variant,
                currency: track.currency(),
              })
          }
          function enhancedEcommerceProductAction(track, action, data) {
            enhancedEcommerceTrackProduct(track),
              window.ga('ec:setAction', action, data || {})
          }
          function extractCheckoutOptions(props) {
            var options = [props.paymentMethod, props.shippingMethod],
              valid = select(options, function (e) {
                return e
              })
            return valid.length > 0 ? valid.join(', ') : null
          }
          function createProductTrack(track, properties) {
            return (
              (properties.currency = properties.currency || track.currency()),
              new Track({ properties: properties })
            )
          }
          ;(GA.prototype.completedOrderEnhanced = function (track) {
            var total = track.total() || track.revenue() || 0,
              orderId = track.orderId(),
              products = track.products(),
              props = track.properties()
            orderId &&
              (STRIPE_ZERO_DECIMAL_CURRENCIES.has(track.currency()) &&
                (total *= 100),
              this.loadEnhancedEcommerce(track),
              each(products, function (product) {
                var productTrack
                enhancedEcommerceTrackProduct(
                  createProductTrack(track, product)
                )
              }),
              window.ga('ec:setAction', 'purchase', {
                id: orderId,
                affiliation: props.affiliation,
                revenue: total,
                tax: track.tax(),
                shipping: track.shipping(),
                coupon: track.coupon(),
              }),
              this.pushEnhancedEcommerce(track))
          }),
            (GA.prototype.refundedOrderEnhanced = function (track) {
              var orderId = track.orderId(),
                products = track.products()
              orderId &&
                (this.loadEnhancedEcommerce(track),
                each(products, function (product) {
                  var track = new Track({ properties: product })
                  window.ga('ec:addProduct', {
                    id: track.id() || track.sku(),
                    quantity: track.quantity(),
                  })
                }),
                window.ga('ec:setAction', 'refund', { id: orderId }),
                this.pushEnhancedEcommerce(track))
            }),
            (GA.prototype.addedProductEnhanced = function (track) {
              this.loadEnhancedEcommerce(track),
                enhancedEcommerceProductAction(track, 'add'),
                this.pushEnhancedEcommerce(track)
            }),
            (GA.prototype.removedProductEnhanced = function (track) {
              this.loadEnhancedEcommerce(track),
                enhancedEcommerceProductAction(track, 'remove'),
                this.pushEnhancedEcommerce(track)
            }),
            (GA.prototype.viewedProductEnhanced = function (track) {
              this.loadEnhancedEcommerce(track),
                enhancedEcommerceProductAction(track, 'detail'),
                this.pushEnhancedEcommerce(track)
            }),
            (GA.prototype.clickedProductEnhanced = function (track) {
              var props = track.properties()
              this.loadEnhancedEcommerce(track),
                enhancedEcommerceProductAction(track, 'click', {
                  list: props.list,
                }),
                this.pushEnhancedEcommerce(track)
            }),
            (GA.prototype.viewedPromotionEnhanced = function (track) {
              var props = track.properties()
              this.loadEnhancedEcommerce(track),
                window.ga('ec:addPromo', {
                  id: track.id(),
                  name: track.name(),
                  creative: props.creative,
                  position: props.position,
                }),
                this.pushEnhancedEcommerce(track)
            }),
            (GA.prototype.clickedPromotionEnhanced = function (track) {
              var props = track.properties()
              this.loadEnhancedEcommerce(track),
                window.ga('ec:addPromo', {
                  id: track.id(),
                  name: track.name(),
                  creative: props.creative,
                  position: props.position,
                }),
                window.ga('ec:setAction', 'promo_click', {}),
                this.pushEnhancedEcommerce(track)
            })
        },
        {
          facade: 188,
          defaults: 200,
          'obj-case': 38,
          each: 4,
          'analytics.js-integration': 163,
          is: 16,
          object: 18,
          'global-queue': 204,
          select: 211,
          'use-https': 165,
        },
      ],
      211: [
        function (require, module, exports) {
          var toFunction = require('to-function')
          module.exports = function (arr, fn) {
            var ret = []
            fn = toFunction(fn)
            for (var i = 0; i < arr.length; ++i)
              fn(arr[i], i) && ret.push(arr[i])
            return ret
          }
        },
        { 'to-function': 71 },
      ],
      212: [
        function (require, module, exports) {
          function omit(keys, object) {
            var ret = {}
            for (var item in object) ret[item] = object[item]
            for (var i = 0; i < keys.length; i++) delete ret[keys[i]]
            return ret
          }
          module.exports = omit
        },
        {},
      ],
      213: [
        function (require, module, exports) {
          function pick(obj) {
            for (
              var keys = [].slice.call(arguments, 1), ret = {}, i = 0, key;
              (key = keys[i]);
              i++
            )
              key in obj && (ret[key] = obj[key])
            return ret
          }
          module.exports = pick
        },
        {},
      ],
      214: [
        function (require, module, exports) {
          var some = [].some
          module.exports = function (arr, fn) {
            if (some) return some.call(arr, fn)
            for (var i = 0, l = arr.length; i < l; ++i)
              if (fn(arr[i], i)) return !0
            return !1
          }
        },
        {},
      ],
      215: [
        function (require, module, exports) {
          module.exports = function (arr, fn, initial) {
            for (
              var idx = 0,
                len = arr.length,
                curr = 3 == arguments.length ? initial : arr[idx++];
              idx < len;

            )
              curr = fn.call(null, curr, arr[idx], ++idx, arr)
            return curr
          }
        },
        {},
      ],
      145: [
        function (require, module, exports) {
          var ads = require('ad-params'),
            clone = require('clone'),
            cookie = require('cookie'),
            extend = require('extend'),
            integration = require('analytics.js-integration'),
            json = require('segmentio/json@1.0.0'),
            localstorage = require('store'),
            protocol = require('protocol'),
            send = require('send-json'),
            topDomain = require('top-domain'),
            utm = require('utm-params'),
            uuid = require('uuid'),
            cookieOptions = { maxage: 31536e6, secure: !1, path: '/' },
            Segment =
              (exports =
              module.exports =
                integration('Segment.io').option('apiKey', ''))
          function scheme() {
            return 'http:' === protocol() ? 'http:' : 'https:'
          }
          function noop() {}
          ;(exports.storage = function () {
            return 'file:' === protocol() || 'chrome-extension:' === protocol()
              ? localstorage
              : cookie
          }),
            (exports.global = window),
            (Segment.prototype.initialize = function () {
              var self = this
              this.ready(),
                this.analytics.on('invoke', function (msg) {
                  var action = msg.action(),
                    listener = 'on' + msg.action()
                  self.debug('%s %o', action, msg),
                    self[listener] && self[listener](msg),
                    self.ready()
                })
            }),
            (Segment.prototype.loaded = function () {
              return !0
            }),
            (Segment.prototype.onpage = function (page) {
              this.send('/p', page.json())
            }),
            (Segment.prototype.onidentify = function (identify) {
              this.send('/i', identify.json())
            }),
            (Segment.prototype.ongroup = function (group) {
              this.send('/g', group.json())
            }),
            (Segment.prototype.ontrack = function (track) {
              var json = track.json()
              delete json.traits, this.send('/t', json)
            }),
            (Segment.prototype.onalias = function (alias) {
              var json = alias.json(),
                user = this.analytics.user()
              ;(json.previousId =
                json.previousId ||
                json.from ||
                user.id() ||
                user.anonymousId()),
                (json.userId = json.userId || json.to),
                delete json.from,
                delete json.to,
                this.send('/a', json)
            }),
            (Segment.prototype.normalize = function (msg) {
              this.debug('normalize %o', msg)
              var user = this.analytics.user(),
                global,
                query = exports.global.location.search,
                ctx = (msg.context = msg.context || msg.options || {})
              return (
                delete msg.options,
                (msg.writeKey = this.options.apiKey),
                (ctx.userAgent = navigator.userAgent),
                ctx.library ||
                  (ctx.library = {
                    name: 'analytics.js',
                    version: this.analytics.VERSION,
                  }),
                query && (ctx.campaign = utm(query)),
                this.referrerId(query, ctx),
                (msg.userId = msg.userId || user.id()),
                (msg.anonymousId = user.anonymousId()),
                (msg.messageId = uuid()),
                (msg.sentAt = new Date()),
                this.debug('normalized %o', msg),
                msg
              )
            }),
            (Segment.prototype.send = function (path, msg, fn) {
              var url = scheme() + '//api.segment.io/v1' + path,
                headers = { 'Content-Type': 'text/plain' }
              fn = fn || noop
              var self = this
              ;(msg = this.normalize(msg)),
                send(url, msg, headers, function (err, res) {
                  if ((self.debug('sent %O, received %O', msg, arguments), err))
                    return fn(err)
                  ;(res.url = url), fn(null, res)
                })
            }),
            (Segment.prototype.cookie = function (name, val) {
              var store = Segment.storage()
              if (1 === arguments.length) return store(name)
              var global = exports.global,
                href = global.location.href,
                domain = '.' + topDomain(href)
              '.' === domain && (domain = ''),
                this.debug('store domain %s -> %s', href, domain)
              var opts = clone(cookieOptions)
              ;(opts.domain = domain),
                this.debug('store %s, %s, %o', name, val, opts),
                store(name, val, opts),
                store(name) ||
                  (delete opts.domain,
                  this.debug('fallback store %s, %s, %o', name, val, opts),
                  store(name, val, opts))
            }),
            (Segment.prototype.referrerId = function (query, ctx) {
              var stored = this.cookie('s:context.referrer'),
                ad
              stored && (stored = json.parse(stored)),
                query && (ad = ads(query)),
                (ad = ad || stored) &&
                  ((ctx.referrer = extend(ctx.referrer || {}, ad)),
                  this.cookie('s:context.referrer', json.stringify(ad)))
            })
        },
        {
          'ad-params': 216,
          clone: 11,
          cookie: 55,
          extend: 65,
          'analytics.js-integration': 163,
          'segmentio/json@1.0.0': 56,
          store: 217,
          protocol: 218,
          'send-json': 219,
          'top-domain': 186,
          'utm-params': 220,
          uuid: 75,
        },
      ],
      216: [
        function (require, module, exports) {
          var parse = require('querystring').parse
          module.exports = ads
          var QUERYIDS = { btid: 'dataxu', urid: 'millennial-media' }
          function ads(query) {
            var params = parse(query)
            for (var key in params)
              for (var id in QUERYIDS)
                if (key === id) return { id: params[key], type: QUERYIDS[id] }
          }
        },
        { querystring: 221 },
      ],
      221: [
        function (require, module, exports) {
          var encode = encodeURIComponent,
            decode = decodeURIComponent,
            trim = require('trim'),
            type = require('type'),
            pattern = /(\w+)\[(\d+)\]/
          ;(exports.parse = function (str) {
            if ('string' != typeof str) return {}
            if ('' == (str = trim(str))) return {}
            '?' == str.charAt(0) && (str = str.slice(1))
            for (
              var obj = {}, pairs = str.split('&'), i = 0;
              i < pairs.length;
              i++
            ) {
              var parts = pairs[i].split('='),
                key = decode(parts[0]),
                m
              ;(m = pattern.exec(key))
                ? ((obj[m[1]] = obj[m[1]] || []),
                  (obj[m[1]][m[2]] = decode(parts[1])))
                : (obj[parts[0]] = null == parts[1] ? '' : decode(parts[1]))
            }
            return obj
          }),
            (exports.stringify = function (obj) {
              if (!obj) return ''
              var pairs = []
              for (var key in obj) {
                var value = obj[key]
                if ('array' != type(value))
                  pairs.push(encode(key) + '=' + encode(obj[key]))
                else
                  for (var i = 0; i < value.length; ++i)
                    pairs.push(
                      encode(key + '[' + i + ']') + '=' + encode(value[i])
                    )
              }
              return pairs.join('&')
            })
        },
        { trim: 51, type: 43 },
      ],
      217: [
        function (require, module, exports) {
          var unserialize = require('unserialize'),
            each = require('each'),
            storage
          try {
            storage = window.localStorage
          } catch (e) {
            storage = null
          }
          function store(key, value) {
            var length = arguments.length
            return 0 == length
              ? all()
              : 2 <= length
              ? set(key, value)
              : 1 == length
              ? null == key
                ? storage.clear()
                : 'string' == typeof key
                ? get(key)
                : 'object' == typeof key
                ? each(key, set)
                : void 0
              : void 0
          }
          function set(key, val) {
            return null == val
              ? storage.removeItem(key)
              : storage.setItem(key, JSON.stringify(val))
          }
          function get(key) {
            return unserialize(storage.getItem(key))
          }
          function all() {
            for (var len = storage.length, ret = {}, key; 0 <= --len; )
              ret[(key = storage.key(len))] = get(key)
            return ret
          }
          ;(module.exports = store), (store.supported = !!storage)
        },
        { unserialize: 222, each: 174 },
      ],
      222: [
        function (require, module, exports) {
          module.exports = function (val) {
            try {
              return JSON.parse(val)
            } catch (e) {
              return val || void 0
            }
          }
        },
        {},
      ],
      218: [
        function (require, module, exports) {
          var define = Object.defineProperty,
            initialProtocol = window.location.protocol,
            mockedProtocol
          function get() {
            return mockedProtocol || window.location.protocol
          }
          function set(protocol) {
            try {
              define(window.location, 'protocol', {
                get: function () {
                  return protocol
                },
              })
            } catch (err) {
              mockedProtocol = protocol
            }
          }
          ;(module.exports = function (protocol) {
            return 0 === arguments.length ? get() : set(protocol)
          }),
            (module.exports.http = function () {
              set('http:')
            }),
            (module.exports.https = function () {
              set('https:')
            }),
            (module.exports.reset = function () {
              set(initialProtocol)
            })
        },
        {},
      ],
      219: [
        function (require, module, exports) {
          var encode = require('base64-encode'),
            cors = require('has-cors'),
            jsonp = require('jsonp'),
            JSON = require('json')
          function json(url, obj, headers, fn) {
            3 == arguments.length && ((fn = headers), (headers = {}))
            var req = new XMLHttpRequest()
            for (var k in ((req.onerror = fn),
            (req.onreadystatechange = done),
            req.open('POST', url, !0),
            headers))
              req.setRequestHeader(k, headers[k])
            function done() {
              if (4 == req.readyState) return fn(null, req)
            }
            req.send(JSON.stringify(obj))
          }
          function base64(url, obj, _, fn) {
            3 == arguments.length && (fn = _)
            var prefix = exports.prefix
            ;(obj = encode(JSON.stringify(obj))),
              (obj = encodeURIComponent(obj)),
              jsonp(
                (url += '?' + prefix + '=' + obj),
                { param: exports.callback },
                function (err, obj) {
                  if (err) return fn(err)
                  fn(null, { url: url, body: obj })
                }
              )
          }
          ;((exports = module.exports = cors ? json : base64).callback =
            'callback'),
            (exports.prefix = 'data'),
            (exports.json = json),
            (exports.base64 = base64),
            (exports.type = cors ? 'xhr' : 'jsonp')
        },
        { 'base64-encode': 223, 'has-cors': 224, jsonp: 225, json: 56 },
      ],
      223: [
        function (require, module, exports) {
          var utf8Encode = require('utf8-encode'),
            keyStr =
              'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/='
          function encode(input) {
            var output = '',
              chr1,
              chr2,
              chr3,
              enc1,
              enc2,
              enc3,
              enc4,
              i = 0
            for (input = utf8Encode(input); i < input.length; )
              (enc1 = (chr1 = input.charCodeAt(i++)) >> 2),
                (enc2 =
                  ((3 & chr1) << 4) | ((chr2 = input.charCodeAt(i++)) >> 4)),
                (enc3 =
                  ((15 & chr2) << 2) | ((chr3 = input.charCodeAt(i++)) >> 6)),
                (enc4 = 63 & chr3),
                isNaN(chr2) ? (enc3 = enc4 = 64) : isNaN(chr3) && (enc4 = 64),
                (output =
                  output +
                  keyStr.charAt(enc1) +
                  keyStr.charAt(enc2) +
                  keyStr.charAt(enc3) +
                  keyStr.charAt(enc4))
            return output
          }
          module.exports = encode
        },
        { 'utf8-encode': 226 },
      ],
      226: [
        function (require, module, exports) {
          function encode(string) {
            string = string.replace(/\r\n/g, '\n')
            for (var utftext = '', n = 0; n < string.length; n++) {
              var c = string.charCodeAt(n)
              c < 128
                ? (utftext += String.fromCharCode(c))
                : c > 127 && c < 2048
                ? ((utftext += String.fromCharCode((c >> 6) | 192)),
                  (utftext += String.fromCharCode((63 & c) | 128)))
                : ((utftext += String.fromCharCode((c >> 12) | 224)),
                  (utftext += String.fromCharCode(((c >> 6) & 63) | 128)),
                  (utftext += String.fromCharCode((63 & c) | 128)))
            }
            return utftext
          }
          module.exports = encode
        },
        {},
      ],
      224: [
        function (require, module, exports) {
          try {
            module.exports =
              'undefined' != typeof XMLHttpRequest &&
              'withCredentials' in new XMLHttpRequest()
          } catch (err) {
            module.exports = !1
          }
        },
        {},
      ],
      225: [
        function (require, module, exports) {
          var debug = require('debug')('jsonp')
          module.exports = jsonp
          var count = 0
          function noop() {}
          function jsonp(url, opts, fn) {
            'function' == typeof opts && ((fn = opts), (opts = {})),
              opts || (opts = {})
            var prefix = opts.prefix || '__jp',
              param = opts.param || 'callback',
              timeout = null != opts.timeout ? opts.timeout : 6e4,
              enc = encodeURIComponent,
              target =
                document.getElementsByTagName('script')[0] || document.head,
              script,
              timer,
              id = prefix + count++
            function cleanup() {
              script.parentNode.removeChild(script), (window[id] = noop)
            }
            timeout &&
              (timer = setTimeout(function () {
                cleanup(), fn && fn(new Error('Timeout'))
              }, timeout)),
              (window[id] = function (data) {
                debug('jsonp got', data),
                  timer && clearTimeout(timer),
                  cleanup(),
                  fn && fn(null, data)
              }),
              (url = (url +=
                (~url.indexOf('?') ? '&' : '?') +
                param +
                '=' +
                enc(id)).replace('?&', '?')),
              debug('jsonp req "%s"', url),
              ((script = document.createElement('script')).src = url),
              target.parentNode.insertBefore(script, target)
          }
        },
        { debug: 13 },
      ],
      220: [
        function (require, module, exports) {
          var parse = require('querystring').parse
          function utm(query) {
            '?' == query.charAt(0) && (query = query.substring(1))
            var query = query.replace(/\?/g, '&'),
              params = parse(query),
              param,
              ret = {}
            for (var key in params)
              ~key.indexOf('utm_') &&
                ('campaign' == (param = key.substr(4)) && (param = 'name'),
                (ret[param] = params[key]))
            return ret
          }
          module.exports = utm
        },
        { querystring: 221 },
      ],
      227: [
        function (require, module, exports) {
          function toUnixTimestamp(date) {
            return Math.floor(date.getTime() / 1e3)
          }
          module.exports = toUnixTimestamp
        },
        {},
      ],
      162: [
        function (require, module, exports) {
          var integration = require('analytics.js-integration'),
            push = require('global-queue')('SumoMe')
          module.exports = exports = function (analytics) {
            analytics.addIntegration(SumoMe)
          }
          var SumoMe = (exports.Integration = integration('SumoMe')
            .assumesPageview()
            .global('sumo')
            .option('siteId', '')
            .tag(
              '<script src="//load.sumome.com/" data-sumo-site-id={{siteId}}>'
            )
            .readyOnInitialize())
          SumoMe.on('construct', function (integration) {}),
            (SumoMe.prototype.initialize = function () {
              var options = this.options
              this.load(this.ready)
            }),
            (SumoMe.prototype.loaded = function () {
              return !!window.sumo
            })
        },
        { 'analytics.js-integration': 163, 'global-queue': 204 },
      ],
      5: [
        function (require, module, exports) {
          module.exports = {
            name: 'analytics',
            version: '2.9.1',
            main: 'analytics.js',
            dependencies: {},
            devDependencies: {},
          }
        },
        {},
      ],
    },
    {},
    { 1: '' }
  )
)
