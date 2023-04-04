require "test_helper"

require_relative "../../app/helpers/parse_irs_xml.rb"

# TODO: See if there's a cleaner way to check long recipients_info array.

class ParseIrsXmlTest < ActiveSupport::TestCase
  test "xml file parsing" do
    return_ts, tax_period, _filer_info, _recipients_info =
      parse_irs_xml("test/fixtures/irs1.xml")
    assert return_ts == "2016-08-29T15:59:11-05:00"
    assert tax_period == "2015-12-31"

    return_ts, tax_period, filer_info, _recipients_info =
      parse_irs_xml("test/fixtures/irs2.xml")
    assert return_ts == "2018-05-10T15:53:27-05:00"
    assert tax_period == "2017-12-31"

    return_ts, tax_period, filer_info, _recipients_info =
      parse_irs_xml("test/fixtures/irs3.xml")
    assert return_ts == "2016-07-12T16:39:20-05:00"
    assert tax_period == "2015-12-31"

    return_ts, tax_period, filer_info, _recipients_info =
      parse_irs_xml("test/fixtures/irs4.xml")
    assert return_ts == "2019-06-20T16:19:59-05:00"
    assert tax_period == "2018-12-31"

    return_ts, tax_period, filer_info, _recipients_info =
      parse_irs_xml("test/fixtures/irs5.xml")
    assert return_ts == "2021-06-28T11:43:19-05:00"
    assert tax_period == "2020-12-31"

    return_ts, tax_period, filer_info, _recipients_info =
      parse_irs_xml("test/fixtures/irs6.xml")
    assert return_ts == "2018-11-26T17:33:42-06:00"
    assert tax_period == "2016-12-31"

    # The filer information is the same for the first four XML files.
    [1, 2, 3, 4, 5, 6].each do |i|
      _return_ts, _tax_period, filer_info, _recipients_info =
        parse_irs_xml("test/fixtures/irs#{i}.xml")
      ein, name, address_line_1, city, state, zip = filer_info
      assert ein == "200253310"
      assert name == "Pasadena Community Foundation"
      assert address_line_1 == "301 E Colorado Blvd No 810"
      assert city == "Pasadena"
      assert state == "CA"
      assert zip == "91101"
    end

    return_ts, tax_period, filer_info, _recipients_info =
      parse_irs_xml("test/fixtures/irs7.xml")
    assert return_ts == "2021-08-31T08:01:32-05:00"
    assert tax_period == "2020-12-31"

    ein, name, address_line_1, city, state, zip = filer_info
    assert ein == "742805201"
    assert name == "THE H ALAN & KAREN K BELL FAMILY"
    assert address_line_1 == "3015 CHERRY HILL ROAD"
    assert city == "MANHATTAN"
    assert state == "KS"
    assert zip == "66503"

    return_ts, tax_period, filer_info, _recipients_info =
      parse_irs_xml("test/fixtures/irs8.xml")
    assert return_ts == "2018-05-15T08:49:59-05:00"
    assert tax_period == "2017-12-31"

    ein, name, address_line_1, city, state, zip = filer_info
    assert ein == "472387053"
    assert name == "Louis L Borick Foundation"
    assert address_line_1 == "2707 Kipling St"
    assert city == "Houston"
    assert state == "TX"
    assert zip == "77098"
  end
end
