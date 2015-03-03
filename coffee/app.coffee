process = require('./process.js')
s3 = require('./lib/s3.js')
d3 = require('d3')
moment = require('moment')



angular.module('market-playback', ['ui.bootstrap', 'autocomplete'])
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
  $scope.chosenSymbol = 'SSI'
  $scope.symbolSelected = () ->
    select_symbol($scope.chosenSymbol)

  $scope.symbols = ['ACB', 'ADC', 'ALT', 'ALV', 'AMC', 'AME', 'AMV', 'APG',
  'API', 'APP', 'APS', 'ARM', 'ASA', 'B82', 'BAM', 'BBS', 'BCC', 'BDB', 'BED',
  'BHT', 'BII', 'BKC', 'BLF', 'BPC', 'BSC', 'BST', 'BTH', 'BTS', 'BVG', 'BVS',
  'BXH', 'C92', 'CAN', 'CAP', 'CCM', 'CEO', 'CHP', 'CID', 'CJC', 'CKV', 'CMC',
  'CMI', 'CMS', 'CPC', 'CSC', 'CT6', 'CTA', 'CTB', 'CTC', 'CTM', 'CTN', 'CTS',
  'CTX', 'CVN', 'CVT', 'CX8', 'D11', 'DAC', 'DAD', 'DAE', 'DBC', 'DBT', 'DC2',
  'DC4', 'DCS', 'DGC', 'DHP', 'DHT', 'DID', 'DIH', 'DL1', 'DLR', 'DNC', 'DNM',
  'DNP', 'DNY', 'DPC', 'DST', 'DXP', 'DZM', 'EBS', 'ECI', 'EFI', 'EID', 'FDT',
  'FIT', 'GLT', 'GMX', 'HAD', 'HAT', 'HBE', 'HBS', 'HCC', 'HCT', 'HDA', 'HDO',
  'HEV', 'HGM', 'HHC', 'HHG', 'HJS', 'HLC', 'HLD', 'HLY', 'HMH', 'HNM', 'HOM',
  'HPC', 'HPS', 'HST', 'HTC', 'HTP', 'HUT', 'HVT', 'ICG', 'IDJ', 'IDV', 'INC',
  'INN', 'ITQ', 'IVS', 'KHB', 'KHL', 'KKC', 'KLF', 'KLS', 'KMT', 'KSD', 'KSK',
  'KSQ', 'KST', 'KTS', 'KTT', 'L14', 'L18', 'L35', 'L43', 'L44', 'L61', 'L62',
  'LAS', 'LBE', 'LCD', 'LCS', 'LDP', 'LHC', 'LIG', 'LM3', 'LM7', 'LO5', 'LTC',
  'LUT', 'MAC', 'MAS', 'MAX', 'MCC', 'MCF', 'MCO', 'MDC', 'MEC', 'MHL', 'MIM',
  'MKV', 'MNC', 'NAG', 'NBC', 'NBP', 'NDF', 'NDN', 'NDX', 'NET', 'NFC', 'NGC',
  'NHA', 'NHC', 'NPS', 'NST', 'NTP', 'NVB', 'OCH', 'ONE', 'ORS', 'PCG', 'PCT',
  'PDC', 'PEN', 'PFL', 'PGS', 'PGT', 'PHC', 'PHH', 'PID', 'PIV', 'PJC', 'PLC',
  'PMC', 'PMS', 'POT', 'PPE', 'PPG', 'PPP', 'PPS', 'PRC', 'PSC', 'PSD', 'PSI',
  'PTI', 'PTM', 'PTS', 'PV2', 'PVB', 'PVC', 'PVE', 'PVG', 'PVI', 'PVL', 'PVR',
  'PVS', 'PVV', 'PVX', 'PXA', 'QHD', 'QNC', 'QST', 'QTC', 'RCL', 'S12', 'S55',
  'S74', 'S99', 'SAF', 'SAP', 'SCJ', 'SCL', 'SCR', 'SD1', 'SD2', 'SD4', 'SD5',
  'SD6', 'SD7', 'SD9', 'SDA', 'SDC', 'SDD', 'SDE', 'SDG', 'SDH', 'SDN', 'SDP',
  'SDT', 'SDU', 'SDY', 'SEB', 'SED', 'SFN', 'SGC', 'SGD', 'SGH', 'SHA', 'SHB',
  'SHN', 'SHS', 'SIC', 'SJ1', 'SJC', 'SJE', 'SLS', 'SMT', 'SPI', 'SPP', 'SQC',
  'SRA', 'SRB', 'SSG', 'SSM', 'STC', 'STP', 'SVN', 'TAG', 'TBX', 'TC6', 'TCS',
  'TCT', 'TDN', 'TET', 'TH1', 'THB', 'THS', 'THT', 'TIG', 'TJC', 'TKC', 'TKU',
  'TMC', 'TMX', 'TNG', 'TPH', 'TPP', 'TSB', 'TSM', 'TST', 'TTC', 'TTZ', 'TV2',
  'TV3', 'TV4', 'TVC', 'TVD', 'TXM', 'UNI', 'V12', 'V15', 'V21', 'VAT', 'VBC',
  'VBH', 'VC1', 'VC2', 'VC3', 'VC5', 'VC6', 'VC7', 'VC9', 'VCC', 'VCG', 'VCM',
  'VCR', 'VCS', 'VDL', 'VDS', 'VE1', 'VE2', 'VE3', 'VE4', 'VE8', 'VE9', 'VFR',
  'VGP', 'VGS', 'VHL', 'VIE', 'VIG', 'VIT', 'VIX', 'VKC', 'VLA', 'VMC', 'VMI',
  'VNC', 'VND', 'VNF', 'VNN', 'VNR', 'VNT', 'VPC', 'VTC', 'VTH', 'VTL', 'VTS',
  'VTV', 'VXB', 'WCS', 'WSS', 'E1SSHN30', 'TTB', 'PBP', 'AAM', 'ABT', 'ACC',
  'ACL', 'AGF', 'AGM', 'AGR', 'ANV', 'APC', 'ASM', 'ASP', 'ATA', 'AVF', 'BBC',
  'BCE', 'BCI', 'BGM', 'BHS', 'BIC', 'BID', 'BMC', 'BMI', 'BMP', 'BRC', 'BSI',
  'BT6', 'BTP', 'BTT', 'BVH', 'C21', 'C32', 'C47', 'CCI', 'CCL', 'CDC', 'CIG',
  'CII', 'CLC', 'CLG', 'CLW', 'CMG', 'CMT', 'CMV', 'CMX', 'CNG', 'COM', 'CSM',
  'CTD', 'CTG', 'CTI', 'CYC', 'D2D', 'DAG', 'DCL', 'DCT', 'DHA', 'DHC', 'DHG',
  'DHM', 'DIC', 'DIG', 'DLG', 'DMC', 'DPM', 'DPR', 'DQC', 'DRC', 'DRH', 'DRL',
  'DSN', 'DTA', 'DTL', 'DTT', 'DVP', 'DXG', 'DXV', 'EIB', 'ELC', 'EMC', 'EVE',
  'FCM', 'FCN', 'FDC', 'FLC', 'FMC', 'FPT', 'GAS', 'GDT', 'GIL', 'GMC', 'GMD',
  'GSP', 'GTA', 'GTT', 'HAG', 'HAI', 'HAP', 'HAR', 'HAS', 'HAX', 'HBC', 'HCM',
  'HDC', 'HDG', 'HHS', 'HLG', 'HMC', 'HOT', 'HPG', 'HQC', 'HRC', 'HSG', 'HSI',
  'HT1', 'HTI', 'HTL', 'HTV', 'HU1', 'HU3', 'HVG', 'HVX', 'ICF', 'IDI', 'IJC',
  'IMP', 'ITA', 'ITC', 'ITD', 'JVC', 'KAC', 'KBC', 'KDC', 'KDH', 'KHA', 'KHP',
  'KMR', 'KSA', 'KSB', 'KSH', 'KSS', 'KTB', 'L10', 'LAF', 'LBM', 'LCG', 'LCM',
  'LGC', 'LGL', 'LHG', 'LIX', 'LM8', 'LSS', 'MBB', 'MCG', 'MCP', 'MDG', 'MHC',
  'MPC', 'MSN', 'MTG', 'NAV', 'NBB', 'NHS', 'NKG', 'NLG', 'NNC', 'NSC', 'NTL',
  'NVN', 'NVT', 'OGC', 'OPC', 'PAC', 'PAN', 'PDN', 'PDR', 'PET', 'PGC', 'PGD',
  'PGI', 'PHR', 'PIT', 'PJT', 'PNC', 'PNJ', 'POM', 'PPC', 'PPI', 'PTB', 'PTC',
  'PTK', 'PTL', 'PVD', 'PVT', 'PXI', 'PXL', 'PXS', 'PXT', 'QCG', 'RAL', 'RDP',
  'REE', 'RIC', 'SAM', 'SAV', 'SBA', 'SBT', 'SC5', 'SCD', 'SEC', 'SFC', 'SFI',
  'SGT', 'SHI', 'SHP', 'SII', 'SJD', 'SJS', 'SMA', 'SMC', 'SPM', 'SRC', 'SRF',
  'SSC', 'SSI', 'ST8', 'STB', 'STG', 'STT', 'SVC', 'SVI', 'SVT', 'SZL', 'TAC',
  'TBC', 'TCL', 'TCM', 'TCO', 'TCR', 'TDC', 'TDH', 'TDW', 'THG', 'TIC', 'TIE',
  'TIX', 'TLG', 'TLH', 'TMP', 'TMS', 'TMT', 'TNA', 'TNC', 'TNT', 'TPC', 'TRA',
  'TRC', 'TS4', 'TSC', 'TTF', 'TTP', 'TV1', 'TYA', 'UDC', 'UIC', 'VCB', 'VCF',
  'VFG', 'VHC', 'VHG', 'VIC', 'VID', 'VIP', 'VIS', 'VLF', 'VMD', 'VNA', 'VNE',
  'VNG', 'VNH', 'VNI', 'VNL', 'VNM', 'VNS', 'VOS', 'VPH', 'VPK', 'VRC', 'VSC',
  'VSH', 'VSI', 'VST', 'VTB', 'VTF', 'VTO', 'MWG', 'QBS', 'CAV', 'GTN', 'SFG',
  'SKG', 'TVS', 'CLL', 'NCT', 'E1VFVN3']


  """ Loading stock """
  url = 'http://54.148.105.53:8080/pack/transactions?'
  stacked_chart = s3.StackedChart(d3.select('#chart'))
  curr_id = 0

  $scope.alert_msg = ''
  alert = (message) ->
    $scope.$apply(() -> $scope.alert_msg = message)

  play_data = (data, chart) ->
      index = 1
      id = setInterval(() ->
          index += 1
          chart(process.to_stacked_bar_data(data.slice(0, index)))
          if index >= data.length
            clearInterval(id)
            last = data[data.length - 1]
            last_time = last.time
            date = moment($scope.dt).format('DD/MM/YYYY')
            alert('Play finished, last transaction at price: ' + last.price + ' time: ' + last_time + ' in: ' + date)
      , 200)

      return id

  load_binary_data = (url, callback, err) ->
      xhr = d3.xhr(url)
      xhr.responseType('arraybuffer')
      xhr.response((response) ->
          callback(response.response)
          )

      date = moment($scope.dt).format('DD/MM/YYYY')
      xhr.on('error', () -> alert('There is no data for ' + $scope.symbol + ' in: ' + date))
      xhr.get()

  select_symbol = (symbol) ->
    # set msg directly here since using $apply will result in
    # error: apply already in process
    $scope.alert_msg = 'Loading data for ' + symbol + '...'
    date = moment($scope.dt).format('DD/MM/YYYY')
    $scope.symbol = symbol
    clearInterval(curr_id)
    load_binary_data(url + 'symbol=' + symbol + '&date=' + encodeURIComponent(date) + '&rand=' + Math.random(), (data) ->
          alert('Chart loaded for ' + symbol + ' in: ' + date)
          data = process.decode(data)
          data = process.un_rotate(data)
          # unfortunately, data return from server is reverse
          curr_id = play_data(data.reverse(), stacked_chart)
      )

  select_symbol($scope.chosenSymbol)
)



