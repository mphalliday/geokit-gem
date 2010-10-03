require File.join(File.dirname(__FILE__), 'test_base_geocoder')

Geokit::Geocoders::geocoder_ca = "SOMEKEYVALUE"

class CaGeocoderTest < BaseGeocoderTest #:nodoc: all
  
  CA_SUCCESS=<<-EOF
  <?xml version="1.0" encoding="UTF-8" ?>
  <geodata><latt>49.243396</latt><longt>-123.152608</longt><standard><stnumber>2105</stnumber><staddress>32nd AVE W</staddress><city>Vancouver</city><prov>BC</prov></standard></geodata>
  EOF
  
  CA_REVERSE_SUCCESS=<<-EOF
  <?xml version="1.0" encoding="UTF-8" ?>
  <geodata><latt>49.243082</latt><longt>-123.153491</longt><city>VANCOUVER</city><prov>BC</prov><postal>V6J4A4</postal><stnumber>2101</stnumber><staddress>32nd AVE W</staddress><inlatt>49.243396</inlatt><inlongt>-123.152608</inlongt><distance>0.066</distance><NearRoad>Maple ST</NearRoad><NearRoadDistance>0.074</NearRoadDistance><betweenRoad1>35th</betweenRoad1><betweenRoad2>Valley</betweenRoad2></geodata>
  EOF
  
  def setup
    @ca_full_hash = {:street_address=>"2105 West 32nd Avenue",:city=>"Vancouver", :state=>"BC"}
    @ca_full_loc = Geokit::GeoLoc.new(@ca_full_hash)
    @ca_lnglat_hash = {:lng=>-123.152608,:lat=>49.243396}
    @ca_lnglat_loc = Geokit::GeoLoc.new(@ca_lnglat_hash)
  end  
  
  def test_geocoder_with_geo_loc_with_account
    response = MockSuccess.new
    response.expects(:body).returns(CA_SUCCESS)
    url = "http://geocoder.ca/?stno=2105&addresst=West+32nd+Avenue&city=Vancouver&prov=BC&auth=SOMEKEYVALUE&standard=1&geoit=xml"
    Geokit::Geocoders::CaGeocoder.expects(:call_geocoder_service).with(url).returns(response)
    verify(Geokit::Geocoders::CaGeocoder.geocode(@ca_full_loc))    
  end
  
  def test_service_unavailable
    response = MockFailure.new
    #Net::HTTP.expects(:get_response).with(URI.parse("http://geocoder.ca/?stno=2105&addresst=West+32nd+Avenue&city=Vancouver&prov=BC&auth=SOMEKEYVALUE&geoit=xml")).returns(response)  
    url = "http://geocoder.ca/?stno=2105&addresst=West+32nd+Avenue&city=Vancouver&prov=BC&auth=SOMEKEYVALUE&standard=1&geoit=xml" 
    Geokit::Geocoders::CaGeocoder.expects(:call_geocoder_service).with(url).returns(response)
    assert !Geokit::Geocoders::CaGeocoder.geocode(@ca_full_loc).success   
  end  

  def test_reverse_geocoder_with_geo_loc_with_account
    response = MockSuccess.new
    response.expects(:body).returns(CA_REVERSE_SUCCESS)
    url = "http://geocoder.ca/?auth=SOMEKEYVALUE&latt=49.243396&longt=-123.152608&reverse=1&geoit=xml"
    Geokit::Geocoders::CaGeocoder.expects(:call_geocoder_service).with(url).returns(response)
    verify_reverse(Geokit::Geocoders::CaGeocoder.reverse_geocode(@ca_lnglat_loc))    
  end
  
  private
  
  def verify(location)
    assert_equal "BC", location.state
    assert_equal "Vancouver", location.city 
    assert_equal "49.243396,-123.152608", location.ll 
    assert !location.is_us? 
  end
  def verify_reverse(location)
    assert_equal "BC", location.state
    assert_equal "Vancouver", location.city 
    assert_equal "V6J4A4", location.zip
    assert_equal "49.243082,-123.153491", location.ll 
    assert !location.is_us?
  end
end