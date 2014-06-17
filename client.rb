require 'linode'
require 'parseconfig'
require 'httparty'

DYNDNS_DEBUG = nil

class Client

  @api_key = ""
  @client = nil

  def initialize(api_key)
    if (DYNDNS_DEBUG)
      puts "api_key: #{api_key}"
    end

    @api_key = api_key
    @client = Linode.new(:api_key => @api_key)
  end


  def update(domain, subdomain, new_target)
    domain_id = self.lookup_domainid(domain)
    resource_id = self.lookup_resourceid(domain_id, subdomain)

    @client.domain.resource.update(:domainid => domain_id, 
                                   :resourceid => resource_id,
                                   :target => new_target)
    
  end


#  private

  ## domain must be a domain string like "santoro.tk"
  def lookup_domainid(domain)
    domain_entry = @client.domain.list.keep_if { |entry| entry.domain == domain }.pop

    return domain_entry.domainid    
  end

  ## domain must be a subdomain like "www"
  def lookup_resourceid(domain_id, name)
    resource_entry = @client.domain.resource.list(:domainid => domain_id).keep_if {|x| x.name == name}.pop

    return resource_entry.resourceid
  end
end

config = ParseConfig.new("/etc/linode_dyndns.conf")

api_key = config['api_key']
subdomains = config['domains'].split(',')

client = Client.new(api_key)

subdomains.each do |domain| 
  parts = domain.split(".")

  subdomain = parts.shift
  domain = parts.join(".")
  current_ip = HTTParty.get("http://santoro.tk/ip.php").body

  if DYNDNS_DEBUG
    puts "subdomain: #{subdomain}"
    puts "domain: #{domain}"
    puts "current ip: #{current_ip}"
  end

end
