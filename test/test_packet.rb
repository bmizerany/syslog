require File.dirname(__FILE__) + "/helper"

describe "a syslog packet" do
  
  @p = SyslogProto::Packet.new
  
  it "should embarrass a person who does not set the fields" do
    @p.to_s.should.equal "I AM A JUNK PACKET CUZ MY USER DIDNT SET ME"
  end
  
  it "hostname may not be omitted" do
    lambda {@p.hostname = ""}.should.raise ArgumentError
  end
  
  it "hostname may only contain ASCII characters 33-126 (no spaces!)" do
    lambda {@p.hostname = "linux box"}.should.raise ArgumentError
    lambda {@p.hostname = "\000" + "linuxbox"}.should.raise ArgumentError
    lambda {@p.hostname = "space_station"}.should.not.raise
  end
  
  it "facility may only be set within 0-23 or with a proper string name" do
    lambda {@p.facility = 666}.should.raise ArgumentError
    lambda {@p.facility = "mir space station"}.should.raise ArgumentError
    
    lambda {@p.facility = 16}.should.not.raise
    @p.facility.should.equal 16
    lambda {@p.facility = 'local0'}.should.not.raise
    @p.facility.should.equal 16
  end
  
  it "severity may only be set within 0-7 or with a proper string name" do
    lambda {@p.severity = 9876}.should.raise ArgumentError
    lambda {@p.severity = "omgbroken"}.should.raise ArgumentError
    
    lambda {@p.severity = 6}.should.not.raise
    @p.severity.should.equal 6
    lambda {@p.severity = 'info'}.should.not.raise
    @p.severity.should.equal 6
  end
  
  it "severity can be checked using 'some_severity?' methods" do
    @p.info?.should.equal true
    @p.alert?.should.equal false
    @p.emerg?.should.equal false
  end
  
  it "PRI is calculated from the facility and severity" do
    @p.pri.should.equal 134
  end
  
  it "PRI may only be within 0-191" do
    lambda {@p.pri = 22331}.should.raise ArgumentError
    lambda {@p.pri = "foo"}.should.raise ArgumentError
  end
  
  it "facility and severity are deduced and set from setting a valid PRI" do
    @p.pri = 165
    @p.severity.should.equal 5
    @p.facility.should.equal 20
  end
  
  it "return the proper names for facility and severity" do
    @p.severity_name.should.equal 'notice'
    @p.facility_name.should.equal 'local4'
  end
  
  it "set a message, which apparently can be anything" do
    @p.msg = "exploring ze black hole"
    @p.msg.should.equal "exploring ze black hole"
  end
  
  it "timestamp must conform to the retarded format" do
    @p.generate_timestamp.should.match /(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\s(\s|[1-9])\d\s\d\d:\d\d:\d\d/
  end
  
  it "use the current time and assemble the packet" do
    timestamp = @p.generate_timestamp
    @p.to_s.should.equal "<165>#{timestamp} space_station exploring ze black hole"
  end
  
  it "packets larger than 1024 will be truncated" do
    @p.msg = "space warp" * 1000
    @p.to_s.bytesize.should.equal 1024
  end
  
end
