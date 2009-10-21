
require 'open-uri'
def read_hosts_file(hosts_file="/etc/hosts")
  hosts = {}
  
  open(hosts_file) do |file|
    file.each_line() do |line|
      # skip comments, and unqualified ip_addr entry
      next if line =~ /^\s*#/
      next if line =~ /^\w*$/
      next unless line =~ /^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})/
      next if line =~ /^[0-9\.]*(255)[0-9\.]*\w*/

      hosts[line.split[1]] = line.split[0]
    end
  end

  return hosts
end

