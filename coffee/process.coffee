msgpack = require('msgpack5')()
d3 = require('d3')

un_rotate = (data) ->
    keys = Object.keys(data)
    arrs = keys.map((key) -> data[key])
    arrs = d3.zip.apply(null, arrs)
    data = arrs.map((d) ->
                    ans = {}
                    for v, i in d
                        ans[keys[i]] = v
                    return ans)
    return data

decode = (data) -> msgpack.decode(new Uint8Array(data))

infer_missing_prices = (prices) ->
    """ Try to infer the price step
    (as min difference between any 2 prices from input).
    Then return all missing prices"""
    pairs = d3.zip(prices.slice(0, prices.length - 1), prices.slice(1, prices.length - 1))
    price_step = d3.min(pairs.map((d) -> +(Math.abs(d[1] - d[0]).toFixed(1))))
    hmap = {}
    for p in prices
        hmap[p.toFixed(1)] = ''

    min_price = d3.min(prices)
    max_price = d3.max(prices)
    ans = []
    for p in [min_price..max_price] by price_step
        p = p.toFixed(1)
        if !(p of hmap)
            ans.push(+p)
    return ans


to_stacked_bar_data = (data) ->
    # attempt to label buy/sell side
    price_data = data.map((d) -> {'price': d.price, 'volume': d.volume})

    get_color = (last, next) ->
        if last is null
            return 'blue'
        if next > last
            return 'green'
        else if next < last
            return 'red'
        else
            return null

    last_price = null
    last_color = null

    price_data.forEach((d) ->
            d.color = get_color(last_price, d.price) || last_color
            last_price = d.price
            last_color = d.color
        )

    vol_map = d3.nest()
        .key((d) -> d.price).sortKeys(d3.ascending)
        .rollup((leaves) -> leaves.map((d) -> {'value': d.volume, 'color': d.color}))
        .entries(price_data)

    missing_prices = infer_missing_prices(vol_map.map((d) -> +(d.key)))
    for p in missing_prices
        vol_map.push({key: p, values: [{color: 'blue', value: 0}]})
    vol_map = vol_map.sort((a,b) -> d3.ascending(a.key, b.key))
    return vol_map.map((d) -> {'name': d.key, 'values': d.values})

module.exports.process = process
module.exports.decode = decode
module.exports.un_rotate = un_rotate
module.exports.to_stacked_bar_data = to_stacked_bar_data
module.exports.infer_missing_prices = infer_missing_prices
