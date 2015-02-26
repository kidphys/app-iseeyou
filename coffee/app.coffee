process = require('./process.js')
s3 = require('./s3.js')
d3 = require('d3')
moment = require('moment')

play_data = (data, chart) ->
    index = 1
    id = setInterval(() ->
        index += 1
        chart(process.to_stacked_bar_data(data.slice(0, index)))
        if index >= data.length
          clearInterval(id)
    , 200)

    return id

load_binary_data = (url, callback) ->
    xhr = d3.xhr(url)
    xhr.responseType('arraybuffer')
    xhr.response((response) ->
        callback(response.response)
        )
    xhr.get()

angular.module('market-playback', ['ui.bootstrap'])
angular.module('market-playback')
.controller('DatePicker', ($scope) ->
  $scope.today = () -> $scope.dt = new Date()
  $scope.today()

  $scope.clear = () -> $scope.dt = null

  # Disable weekend selection
  $scope.disabled = (date, mode) ->
    return ( mode == 'day' && ( date.getDay() == 0 || date.getDay() == 6 ) )

  $scope.toggleMin = () -> $scope.minDate = $scope.minDate ? null : new Date()
  $scope.toggleMin()

  $scope.dateOptions = {
    formatYear: 'yy',
    startingDay: 1
  }

  $scope.formats = ['dd-MMMM-yyyy', 'yyyy/MM/dd', 'dd.MM.yyyy', 'shortDate']
  $scope.format = $scope.formats[0]


  """ Choosing symbol """
  $scope.symbol = 'VND'

  $scope.symbols = ['PVD', 'PVC', 'PGS', 'PGC', 'PVT', 'PVS', 'PVG', 'GSP', 'PXS',
                    'VND', 'KLS', 'BVS', 'SSI', 'HCM', 'SHS', 'ORS', 'VDS', 'IVS', 'HPC', 'AGR', 'WSS', 'BSI',
                    'IDI', 'ATA', 'AVF', 'HVG', 'ANV',
                    'CSM', 'DRC', 'SRC', 'TNC', 'DPR', 'PHR',
                    'TLH', 'VGS', 'HPG', 'VIS', 'HLA',
                    'ITA', 'NTL', 'LCG', 'ITC', 'HQC', 'IJC', 'KBC', 'DXG',
                    'VCB', 'MBB', 'CTG', 'ACB', 'EIB', 'BID', 'SHB',
                    'BGM', 'KSS', 'KSH', 'KTB', 'KHB', 'KSD', 'DHM', 'LCM', 'BMC']

  url = 'http://54.148.105.53:8080/pack/transactions?'
  stacked_chart = s3.StackedChart(d3.select('#chart'))
  curr_id = 0

  $scope.select_symbol = (symbol) ->
    date = moment($scope.dt).format('DD/MM/YYYY')
    console.log('Symbol selected', symbol, date)
    $scope.symbol = symbol
    load_binary_data(url + 'symbol=' + symbol + '&date=' + encodeURIComponent(date) + '&rand=' + Math.random(), (data) ->
          clearInterval(curr_id)
          data = process.decode(data)
          data = process.un_rotate(data)
          curr_id = play_data(data, stacked_chart)
      )


)



