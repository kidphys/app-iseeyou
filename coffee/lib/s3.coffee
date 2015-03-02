d3 = require('d3')

StackedChart = (parent, config={}) ->
    """
    Generate a stacked bar chart which can enact new data at each bar.
    This is to illustrate the growth volume of transactions

    Data format:
        data = {
            [name: some_value, values: [
                {value: some_value, color: some_color},
                {value: some_value, color: some_color}
            ]
        }
    Where it will be tracked by name for column. Values will use index to track.
    If color is undefined, default color is used, style it with ".bar rect.old"
    """

    # setup default config if necessary
    width = config.width or 500
    height = config.height or 500
    margin = config.margin or {top: 20, right: 30, bottom: 40, left: 50}
    duration = config.duration or 300
    bar_padding = 0.1

    # inner drawing area with margin
    # this is repetitive
    canvas = parent.append('svg')
                .attr('class', 'chart')
                .attr('width', width + margin.left + margin.right)
                .attr('height', height + margin.top + margin.bottom)
                .append('g')
                .attr('transform',
                    'translate(' + margin.left + ',' + margin.top + ')')

    # setup 2 axes
    yScale = d3.scale.linear()
                .domain([])
                .range([height - 2, 0])  # small pading to lift all bars up away from axis

    yAxis = d3.svg.axis()
                .scale(yScale)
                .orient('left')

    canvas.append('g')
        .attr('class', 'y axis')

    # setup x axis
    left_padding = bar_padding  # just make it even clearer
    right_padding = bar_padding

    xScale = d3.scale.ordinal()
                .domain([])
                .rangeRoundBands([0, width],
                        left_padding, right_padding)

    xAxis = d3.svg.axis()
                .scale(xScale)
                .orient('bottom')

    canvas.append('g')
        .attr('transform', 'translate(0, ' + height + ')')
        .attr('class', 'x axis')

    canvas.append('g')
          .attr('class', 'canvas')


    update = (data) ->
       # update axes
        xScale.domain(data.map((d) -> d.name))
        max_value = d3.max(data.map((d) -> d3.sum(d.values.map((d) -> d.value))))

        data = data.map((d) ->
                ans = {
                    # calculate the cumulative sum and retain the last value
                    values: d.values.reduce((last, next) ->
                            y0 = (last[last.length - 1] && last[last.length - 1].y1) || 0
                            last.push({
                                name: d.name,
                                y0: y0,
                                y1: y0 + next.value,
                                color: next.color
                                })
                            return last
                        , [])
                    name: d.name
                }
                ans.total = ans.values[ans.values.length - 1].y1
                return ans
            )

        yScale.domain([0, d3.max(data.map((d) -> d.total))])
        t = canvas.transition().duration(duration)
        t.select('.x.axis').call(xAxis)
        t.select('.y.axis').call(yAxis)

        bar = canvas.select('.canvas')
                    .selectAll('.bar')
                    .data(data, (d) -> d.name)


        bar.enter()
            .append('g')

        bar.exit().remove()

        bar.attr('class', 'bar')
           .attr('transform', (d) -> 'translate(' + xScale(d.name) + ', 0)')

        rect = bar.selectAll('rect')
            .data (d) -> d.values

        rect.exit().remove()

        # here x is not specified, default to 0
        # since the rect position will depend on its parent group
        rect.transition()
            .duration(duration)
            .attr('class', 'old')
            .attr('width', (d) -> xScale.rangeBand())
            .attr('y', (d) -> yScale(d.y1))
            .attr('height', 0)
            .attr('height', (d) -> yScale(d.y0) - yScale(d.y1))
            .style('fill', (d) -> d.color)

        rect.enter()
            .append('rect')
            .attr('class', 'new')
            .attr('width', (d) -> xScale.rangeBand())
            .attr('height', 0)
            .attr('y', (d) -> yScale(d.y0))

    return update

BarChart = (parent, data, config={}) ->
    """
    Generate a bar chart with name/value pairs
    Sample usage:
        bar_chart = BarChart(d3.select('.chart'), data)
        bar_chart(new_data)  #  update new data
    The chart joins data by value of key 'name'
    """
    # setup default config if necessary
    width = config.width or 500
    height = config.height or 500
    margin = config.margin or {top: 20, right: 30, bottom: 40, left: 40}
    duration = config.duration or 100
    bar_padding = 0.1

    # inner drawing area with margin
    canvas = parent.append('svg')
                .attr('class', 'chart')
                .attr('width', width + margin.left + margin.right)
                .attr('height', height + margin.top + margin.bottom)
                .append('g')
                .attr('transform',
                    'translate(' + margin.left + ',' + margin.top + ')')

    # setup 2 axes
    yScale = d3.scale.linear()
                .domain([0, d3.max(data.map((d) -> d.value))])
                .range([height, 0])

    yAxis = d3.svg.axis()
                .scale(yScale)
                .orient('left')

    canvas.append('g')
        .attr('class', 'y axis')
        .call(yAxis)

    # setup x axis
    left_padding = bar_padding  # just make it even clearer
    right_padding = bar_padding

    xScale = d3.scale.ordinal()
                .domain(data.map((d) -> d.name))
                .rangeRoundBands([0, width],
                        left_padding, right_padding)

    xAxis = d3.svg.axis()
                .scale(xScale)
                .orient('bottom')

    canvas.append('g')
        .attr('transform', 'translate(0, ' + height + ')')
        .attr('class', 'x axis')
        .call(xAxis)


    canvas.append('g')
          .attr('class', 'bar')

    # update data function, can be used to update/init data
    update = (data) ->
        # transite axes
        xScale.domain(data.map((d) -> d.name))
        yScale.domain([0, d3.max(data.map((d) -> d.value))])
        t = canvas.transition().duration(duration)
        t.select('.x.axis').call(xAxis)
        t.select('.y.axis').call(yAxis)

        bar = canvas.select('.bar')
                    .selectAll('.rect')
                    .data(data, (d) -> d.name)

        bar.enter()
            .append('rect')
            .attr('class', 'rect')

        bar.transition()
            .attr('x', (d) -> xScale(d.name))
            .attr('y', (d) -> yScale(d.value))
            .attr('width', (d) -> xScale.rangeBand())
            .attr('height', (d) -> height - yScale(d.value))

        bar.exit().remove()

    update (data)

    return update

module.exports.StackedChart = StackedChart