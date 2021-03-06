# Basic inits

window.isBool = (str) -> str is true or str is false

window.isEmpty = (str) -> not str or str.length is 0

window.isBlank = (str) -> not str or /^\s*$/.test(str)

window.isNull = (str) ->
  try
    if isEmpty(str) or isBlank(str) or not str?
      unless str is false or str is 0 then return true
  catch
  false

window.isJson = (str) ->
  if typeof str is 'object' then return true
  try
    JSON.parse(str)
    return true
  catch
  false

window.isNumber = (n) -> not isNaN(parseFloat(n)) and isFinite(n)

window.toFloat = (str) ->
  if not isNumber(str) or isNull(str) then return 0
  parseFloat(str)

window.toInt = (str) ->
  if not isNumber(str) or isNull(str) then return 0
  parseInt(str)

`function toObject(arr) {
    var rv = {};
    for (var i = 0; i < arr.length; ++i)
        if (arr[i] !== undefined) rv[i] = arr[i];
    return rv;
}`


# https://gist.github.com/andrei-m/982927#gistcomment-1797205
# TODO integrate with https://gist.github.com/andrei-m/982927#gistcomment-1931258
`String.prototype.levenshtein = function(string) {
    var a = this, b = string + "", m = [], i, j, min = Math.min;

    if (!(a && b)) return (b || a).length;

    for (i = 0; i <= b.length; m[i] = [i++]);
    for (j = 0; j <= a.length; m[0][j] = j++);

    for (i = 1; i <= b.length; i++) {
        for (j = 1; j <= a.length; j++) {
            m[i][j] = b.charAt(i - 1) == a.charAt(j - 1)
                ? m[i - 1][j - 1]
                : m[i][j] = min(
                    m[i - 1][j - 1] + 1,
                    min(m[i][j - 1] + 1, m[i - 1 ][j] + 1))
        }
    }

    return m[b.length][a.length];
}`

# This needs work .... but it'll do for now
Array.closest = (arr, str) ->
  ###
  # Sort an array based on the closeness to a comparison string,
  # using Levenshtein distance or substring
  ###
  return arr.sort (a, b) ->
    # Prioritize substring matches over Levenshtein distance
    aDist = if a.search(str) >= 0 then 0 else a.levenshtein(str)
    bDist = if b.search(str) >= 0 then 0 else b.levenshtein(str)
    if aDist is 0 and bDist is 0
      # Both have the string as a substring
      aDist = a.levenshtein(str)
      bDist = b.levenshtein(str)
    return aDist - bDist



String::toBool = -> this.toString() is 'true'

Boolean::toBool = -> this.toString() is 'true' # In case lazily tested

Object.size = (obj) ->
  size = 0
  size++ for key of obj when obj.hasOwnProperty(key)
  size

window.delay = (ms,f) -> setTimeout(f,ms)

window.roundNumber = (number,digits = 0) ->
  multiple = 10 ** digits
  Math.round(number * multiple) / multiple

jQuery.fn.exists = -> jQuery(this).length > 0

window.byteCount = (s) => encodeURI(s).split(/%..|./).length - 1

`function shuffle(o) { //v1.0
    for (var j, x, i = o.length; i; j = Math.floor(Math.random() * i), x = o[--i], o[i] = o[j], o[j] = x);
    return o;
}`

window.debounce_timer = null
window.debounce = (func, threshold = 300, execAsap = false) ->
  # Borrowed from http://coffeescriptcookbook.com/chapters/functions/debounce
  # Only run the prototyped function once per interval.
  (args...) ->
    obj = this
    delayed = ->
      func.apply(obj, args) unless execAsap
    if window.debounce_timer?
      clearTimeout(window.debounce_timer)
    else if (execAsap)
      func.apply(obj, args)
    window.debounce_timer = setTimeout(delayed, threshold)


Function::getName = ->
  ###
  # Returns a unique identifier for a function
  ###
  name = this.name
  unless name?
    name = this.toString().substr( 0, this.toString().indexOf( "(" ) ).replace( "function ", "" );
  if isNull name
    name = md5 this.toString()
  name

Function::debounce = (threshold = 300, execAsap = false, timeout = window.debounce_timer, args...) ->
  ###
  # Borrowed from http://coffeescriptcookbook.com/chapters/functions/debounce
  # Only run the prototyped function once per interval.
  #
  # @param threshold -> Timeout in ms
  # @param execAsap -> Do it NAOW
  # @param timeout -> backup timeout object
  ###
  unless window.core?.debouncers?
    unless window.core?
      window.core = new Object()
    core.debouncers = new Object()
  try
    key = this.getName()
  try
    if core.debouncers[key]?
      timeout = core.debouncers[key]
  func = this
  delayed = ->
    if key?
      clearTimeout timeout
      delete core.debouncers[key]
    func.apply(func, args) unless execAsap
    #console.info("Debounce applied")
  if timeout?
    try
      clearTimeout timeout
  if execAsap
    func.apply(obj, args)
    console.log("Executed #{key} immediately")
    return false
  if key?
    #console.log "Debouncing '#{key}' for #{threshold} ms"
    core.debouncers[key] = delay threshold, ->
      delayed()
  else
    #console.log "Delaying '#{key}' for #{threshold} ms"
    window.debounce_timer = delay threshold, ->
      delayed()


window.mapNewWindows = ->
  # Do new windows
  $(".newwindow").each ->
    # Add a click and keypress listener to
    # open links with this class in a new window
    curHref = $(this).attr("href")
    openInNewWindow = (url) ->
      if not url? then return false
      window.open(url)
      return false
    $(this).click ->
      openInNewWindow(curHref)
    $(this).keypress ->
      openInNewWindow(curHref)

# Animations

window.toastStatusMessage = (message, className = "error", duration = 3000, selector = "#status-message") ->
  if not isNumber(duration)
    duration = 3000
  if selector.slice(0,1) is not "#"
    selector = "##{selector}"
  if not $(selector).exists()
    html = "<paper-toast id=\"#{selector.slice(1)}\" duration=\"#{duration}\"></paper-toast>"
    $(html).appendTo("body")
  $(selector).attr("text",message)
  $(selector).addClass(className)
  $(selector)[0].show()
  delay duration + 500, ->
    # A short time after it hides, clean it up
    $(selector).empty()
    $(selector).removeClass(className)
    $(selector).attr("text","")

window.animateLoad = (d=50,elId="#status-container") ->
  if elId.slice(0,1) isnt "#" then elId = "##{elId}"
  try
    if not $(elId).exists()
      inlineId = elId.slice(1)
      html = "<div id='status-container'> <div class='ball stop hide'></div><div class='ball1 stop hide'></div> <br/><p id='status-message'></p> </div>"
      $(html).appendTo("body")
    if $(elId).exists()
      sm_d = roundNumber(d * .5)
      big = $(elId).find('.ball')
      small = $(elId).find('.ball1')
      big.removeClass('stop hide')
      big.css
        width:"#{d}px"
        height:"#{d}px"
      offset = roundNumber(d / 2 + sm_d/2 + 9)
      offset2 = roundNumber((d + 10) / 2 - (sm_d+6)/2)
      small.removeClass('stop hide')
      small.css
        width:"#{sm_d}px"
        height:"#{sm_d}px"
        top:"-#{offset}px"
        'margin-left':"#{offset2}px"
      return true
    false
  catch e
    console.error('Could not animate loader', e.message);

window.stopLoad = (elId="#status-container",fadeOut = 500) ->
  if elId.slice(0,1) isnt "#" then elId = "##{elId}"
  try
    if $(elId).exists()
      big = $(elId).find('.ball')
      small = $(elId).find('.ball1')
      big.addClass('bballgood ballgood')
      small.addClass('bballgood ball1good')
      delay fadeOut, ->
        big.addClass('stop hide')
        big.removeClass('bballgood ballgood')
        small.addClass('stop hide')
        small.removeClass('bballgood ball1good')
  catch e
    console.error('Could not stop load animation', e.message)


window.stopLoadError = (message,elId="#status-container",fadeOut = 1500) ->
  if elId.slice(0,1) isnt "#" then elId = "##{elId}"
  try
    if $(elId).exists()
      big = $(elId).find('.ball')
      small = $(elId).find('.ball1')
      big.addClass('bballerror ballerror')
      small.addClass('bballerror ball1error')
      delay fadeOut, ->
        big.addClass('stop hide')
        big.removeClass('bballerror ballerror')
        small.addClass('stop hide')
        small.removeClass('bballerror ball1error')
      if message? then toastStatusMessage(message)
  catch e
    console.error('Could not stop load error animation', e.message)

window.openLink = (url) ->
  if not url? then return false
  window.open(url)
  false

window.openTab = (url) ->
  openLink(url)

window.goTo = (url) ->
  if not url? then return false
  window.location.href = url
  false


window.loadJS = (src, callback = new Object(), doCallbackOnError = true) ->
  ###
  # Load a new javascript file
  #
  # If it's already been loaded, jump straight to the callback
  #
  # @param string src The source URL of the file
  # @param function callback Function to execute after the script has
  #                          been loaded
  # @param bool doCallbackOnError Should the callback be executed if
  #                               loading the script produces an error?
  ###
  if $("script[src='#{src}']").exists()
    if typeof callback is "function"
      try
        callback()
      catch e
        console.error "Script is already loaded, but there was an error executing the callback function - #{e.message}"
    # Whether or not there was a callback, end the script
    return true
  # Create a new DOM selement
  s = document.createElement("script")
  # Set all the attributes. We can be a bit redundant about this
  s.setAttribute("src",src)
  s.setAttribute("async","async")
  s.setAttribute("type","text/javascript")
  s.src = src
  s.async = true
  # Onload function
  onLoadFunction = ->
    state = s.readyState
    try
      if not callback.done and (not state or /loaded|complete/.test(state))
        callback.done = true
        if typeof callback is "function"
          try
            callback()
          catch e
            console.error "Postload callback error for #{src} - #{e.message}"
            console.warn e.stack
    catch e
      console.error "Onload error - #{e.message}"
  # Error function
  errorFunction = ->
    console.warn "There may have been a problem loading #{src}"
    try
      unless callback.done
        callback.done = true
        if typeof callback is "function" and doCallbackOnError
          try
            callback()
          catch e
            console.error "Post error callback error - #{e.message}"
    catch e
      console.error "There was an error in the error handler! #{e.message}"
  # Set the attributes
  s.setAttribute("onload",onLoadFunction)
  s.setAttribute("onreadystate",onLoadFunction)
  s.setAttribute("onerror",errorFunction)
  s.onload = s.onreadystate = onLoadFunction
  s.onerror = errorFunction
  document.getElementsByTagName('head')[0].appendChild(s)
  true

deepJQuery = (selector) ->
  ###
  # Do a shadow-piercing selector
  #
  # Cross-browser, works with Chrome, Firefox, Opera, Safari, and IE
  # Falls back to standard jQuery selector when everything fails.
  ###
  try
    # Chrome uses /deep/ which has been deprecated
    # See http://dev.w3.org/csswg/css-scoping/#deep-combinator
    # https://w3c.github.io/webcomponents/spec/shadow/#composed-trees
    # This is current as of Chrome 44.0.2391.0 dev-m
    # See https://code.google.com/p/chromium/issues/detail?id=446051
    #
    # However, this is pending deprecation.
    unless $("html /deep/ #{selector}").exists()
      throw("Bad /deep/ selector")
    return $("html /deep/ #{selector}")
  catch e
    try
      # Firefox uses >>> instead of "deep"
      # https://developer.mozilla.org/en-US/docs/Web/Web_Components/Shadow_DOM
      # This is actually the correct selector
      unless $("html >>> #{selector}").exists()
        throw("Bad >>> selector")
      return $("html >>> #{selector}")
    catch e
      # These don't match at all -- do the normal jQuery selector
      return $(selector)

p$ = (selector) ->
  # Try to get an object the Polymer way, then if it fails,
  # do jQuery
  try
    $$(selector)[0]
  catch
    $(selector).get(0)

window.d$ = (selector) ->
  deepJQuery(selector)

$ ->
  try
    window.picturefill()
  catch e
    # We don't actually care here, probably hasn't been imported
    console.log("Could not execute picturefill.")
  mapNewWindows()
  try
    # Fix old links
    fragment = $.url().attr("fragment")
    unless isNull fragment
      if fragment.match /.*[\_\W].*/
        replacementSelector = "##{fragment.replace /[\_\W]/g, "-"}"
        if $(replacementSelector).exists()
          $(replacementSelector).get(0).scrollIntoView()
