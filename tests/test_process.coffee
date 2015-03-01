$ = require('../coffee/process')
assert = require('assert')

describe 'Processing chart data', () ->

    it 'should return missing prices', () ->
        prices = $.infer_missing_prices([12.1, 12.2, 12.5])
        assert.deepEqual([12.3, 12.4], prices)

    it 'return empty arr if no missing prices', () ->
        prices = $.infer_missing_prices([12.1, 12.2])
        assert.deepEqual([], prices)

    it 'can handle larger price step', () ->
        prices = $.infer_missing_prices([50.5, 51, 52])
        assert.deepEqual([51.5], prices)

