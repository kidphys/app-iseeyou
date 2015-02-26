msgpack = require('msgpack5')()

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

    return vol_map.map((d) -> {'name': d.key, 'values': d.values})

module.exports.process = process
module.exports.decode = decode
module.exports.un_rotate = un_rotate
module.exports.to_stacked_bar_data = to_stacked_bar_data
