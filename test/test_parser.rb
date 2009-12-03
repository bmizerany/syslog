require File.dirname(__FILE__) + "/helper"

describe "syslog packet parser" do
  
  it "parse some valid packets" do
    p = SyslogProto.parse("<34>Oct 11 22:14:15 mymachine su: 'su root' failed for lonvick on /dev/pts/8")
    p.facility.should.equal 4
    p.severity.should.equal 2
    p.pri.should.equal 34
    p.hostname.should.equal "mymachine"
    p.msg.should.equal "su: 'su root' failed for lonvick on /dev/pts/8"
    p.time.should.equal Time.parse("Oct 11 22:14:15")
    
    p = SyslogProto.parse("<13>Feb  5 17:32:18 10.0.0.99 Use the BFG!")
    p.facility.should.equal 1
    p.severity.should.equal 5
    p.pri.should.equal 13
    p.hostname.should.equal "10.0.0.99"
    p.msg.should.equal "Use the BFG!"
    p.time.should.equal Time.parse("Feb  5 17:32:18")
  end
  
  it "treat a packet with no valid PRI as all content, setting defaults" do
    p = SyslogProto.parse("nomnom")
    p.facility.should.equal 1
    p.severity.should.equal 5
    p.pri.should.equal 13
    p.hostname.should.equal 'unknown'
    p.msg.should.equal "nomnom"
  end
  
  it "PRI with preceding 0's shall be considered invalid" do
    p = SyslogProto.parse("<045>Oct 11 22:14:15 space_station my PRI is not valid")
    p.facility.should.equal 1
    p.severity.should.equal 5
    p.pri.should.equal 13
    p.hostname.should.equal 'unknown'
    p.msg.should.equal "<045>Oct 11 22:14:15 space_station my PRI is not valid"
  end
  
  it "allow the user to pass an origin to be used as the hostname if packet is invalid" do
    p = SyslogProto.parse("<045>Oct 11 22:14:15 space_station my PRI is not valid", '127.0.0.1')
    p.facility.should.equal 1
    p.severity.should.equal 5
    p.pri.should.equal 13
    p.hostname.should.equal '127.0.0.1'
    p.msg.should.equal "<045>Oct 11 22:14:15 space_station my PRI is not valid"
  end
  
end
