Date::addHours = (h) ->
    @setHours @getHours() + h
    @

Array::first = (fn) ->
    @filter(fn)[0]

ALL_CITIES = [
    [ 285, 379 ,'Bia%B3ystok', 'Białystok']
    [ 199, 381 ,'Bydgoszcz', 'Bydgoszcz']
    [ 210, 346 ,'Gda%F1sk', 'Gdańsk']
    [ 152, 390 ,'Gorz%F3w+Wielkopolski', 'Gorzów Wielkopolski']
    [ 215, 461 ,'Katowice', 'Katowice']
    [ 244, 443 ,'Kielce', 'Kielce']
    [ 232, 466 ,'Krak%F3w', 'Kraków']
    [ 277, 432 ,'Lublin', 'Lublin']
    [ 223, 418 ,'%A3%F3d%BC', 'Łódź']
    [ 240, 363 ,'Olsztyn', 'Olsztyn']
    [ 196, 449 ,'Opole', 'Opole']
    [ 180, 400 ,'Pozna%F1', 'Poznań']
    [ 269, 465 ,'Rzesz%F3w', 'Rzeszów']
    [ 142, 370 ,'Szczecin', 'Szczecin']
    [ 209, 383 ,'Toru%F1', 'Toruń']
    [ 250, 406 ,'Warszawa', 'Warszawa']
    [ 181, 436 ,'Wroc%B3aw', 'Wrocław']
    [ 155, 412 ,'Zielona+G%F3ra', 'Zielona Góra']
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
        .html ALL_CITIES.map((c, i) -> "<option>#{c[3]}</option>").join ''
        .val city
        .on 'change', ->
            newCity = $dropdown.val()
            toStorage 'options', { city: newCity }
            updateForecast(newCity)

getCoordinates = (city) ->
    data = ALL_CITIES.first (c) -> c[3] is city
    return {
        col: data[0]
        row: data[1]
    }

updateForecast = (city, lang = defaults.lang) ->
    console.log 'Updating forecast'

    refDate = moment().subtract 4, 'hours'
    refHour = 6 * Math.floor(refDate.hour() / 6)
    date = refDate.format('YYYYMMDD') + (if refHour < 10 then '0' else '') + refHour

    coordinates = getCoordinates(city)

    url = "http://www.meteo.pl/um/metco/mgram_pict.php
            ?ntype=0u
            &fdate=#{date}
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
