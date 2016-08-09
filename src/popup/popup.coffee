Array::first = (fn) ->
    @filter(fn)[0]

ALL_CITIES = [
    [ 285, 379 ,'Białystok']
    [ 199, 381 ,'Bydgoszcz']
    [ 210, 346 ,'Gdańsk']
    [ 152, 390 ,'Gorzów Wielkopolski']
    [ 215, 461 ,'Katowice']
    [ 244, 443 ,'Kielce']
    [ 232, 466 ,'Kraków']
    [ 277, 432 ,'Lublin']
    [ 223, 418 ,'Łódź']
    [ 240, 363 ,'Olsztyn']
    [ 196, 449 ,'Opole']
    [ 180, 400 ,'Poznań']
    [ 269, 465 ,'Rzeszów']
    [ 142, 370 ,'Szczecin']
    [ 209, 383 ,'Toruń']
    [ 250, 406 ,'Warszawa']
    [ 181, 436 ,'Wrocław']
    [ 155, 412 ,'Zielona Góra']
]

defaults =
    lang: 'pl'
    city: 'Warszawa'

fromStorage = (key) ->
    $d = new $.Deferred()
    chrome.storage.local.get key, $d.resolve        
    return $d.promise()
    
toStorage = (key, value) ->
    x = {}
    x[key] = value
    chrome.storage.local.set x

initDropdown = (city) ->
    $dropdown = $('#city')
    $dropdown
        .html ALL_CITIES.map((c, i) -> "<option>#{c[2]}</option>").join ''
        .val city
        .on 'change', ->
            newCity = $dropdown.val()
            toStorage 'options', { city: newCity }
            updateForecast(newCity)

getCoordinates = (city) ->
    data = ALL_CITIES.first (c) -> c[2] is city
    return {
        col: data[0]
        row: data[1]
    }

updateForecast = (city, lang = defaults.lang) ->
    console.log 'Updating forecast'
    coordinates = getCoordinates(city)

    url = "http://www.meteo.pl/um/metco/mgram_pict.php
            ?ntype=0u
            &row=#{coordinates.row}
            &col=#{coordinates.col}
            &lang=#{lang}"
        .replace(/ /g,'')

    console.debug url

    $('.main').html "
        <img src='#{url}' alt='Current weather preview' />
    "

chrome.browserAction.onClicked.addListener updateForecast

window.onload = ->
    fromStorage 'options'
    .then ({options = defaults}) ->
        initDropdown(options.city)
        updateForecast(options.city)
