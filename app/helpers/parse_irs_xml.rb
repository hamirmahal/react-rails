require "nokogiri"
require "open-uri"

# This line exists solely to prevent this error when deploying to Heroku.
# "expected file /app/app/helpers/parse_irs_xml.rb to define constant
# ParseIrsXml, but didn't (Zeitwerk::NameError)"
ParseIrsXml = "some value"

def parse_irs_xml(path_to_xml)
  # doc =
  #   Nokogiri.HTML(
  #     URI.open(
  #       "https://filing-service.s3-us-west-2.amazonaws.com/990-xmls/201612429349300846_public.xml"
  #     )
  #   )
  xmlFile = File.open(path_to_xml)
  doc = Nokogiri.XML(xmlFile)
  xmlFile.close

  filing_path = doc.css("Return/ReturnHeader")
  return_ts = filing_path.css("ReturnTs").text
  # - Parse and store award attributes, such as purpose, cash amount, and tax period
  tax_period = filing_path.css("TaxPeriodEndDt,TaxPeriodEndDate").text

  # - Parse and store ein, name, address, city, state, zip code info for both filers and recipients
  filer_path = filing_path.css("Filer")
  name_path = filer_path.css("Name,BusinessName")
  address_path = filer_path.css("USAddress,AddressUS")
  ein = filer_path.css("EIN").text
  name = name_path.css("BusinessNameLine1,BusinessNameLine1Txt").text
  address_line_1 = address_path.css("AddressLine1,AddressLine1Txt").text
  city = address_path.css("City,CityNm").text
  state = address_path.css("State,StateAbbreviationCd").text
  zip = address_path.css("ZIPCode,ZIPCd").text
  filer_info = [ein, name, address_line_1, city, state, zip]

  # Parse and store ein, name, address, city, state, and zip code
  # information for both filers and recipients.
  recipients_info = Array.new
  recipients = doc.css("Return/ReturnData/IRS990ScheduleI/RecipientTable")
  for recipient in recipients
    ein = recipient.css("EINOfRecipient,RecipientEIN").text
    # Some recipients, like Benton Falls Community Church, don't have an EIN.
    ein = nil if ein == ""
    name =
      recipient.css(
        "RecipientNameBusiness,RecipientBusinessName/BusinessNameLine1,BusinessNameLine1Txt"
      ).text
    if name == ""
      # Don't add a row for entries missing a name.
      next
    end
    address = recipient.css("USAddress,AddressUS")
    address_line_1 = address.css("AddressLine1,AddressLine1Txt").text
    city = address.css("City,CityNm").text
    state = address.css("State,StateAbbreviationCd").text
    zipcode = address.css("ZIPCode,ZIPCd").text
    # - Parse and store award attributes, such as purpose, cash amount, and tax period
    cash_amount = recipient.css("AmountOfCashGrant,CashGrantAmt").text
    purpose = recipient.css("PurposeOfGrantTxt").text
    recipients_info.push(
      [ein, name, address_line_1, city, state, zipcode, cash_amount, purpose]
    )
  end

  return return_ts, tax_period, filer_info, recipients_info
end
